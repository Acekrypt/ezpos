

require 'singleton'
require 'inv/sku.rb'


class CellRender < Gtk::CellRendererText
    attr_accessor :column
    def initialize( parent,model,column )
	super()
	@column = column
	self.editable = true
	signal_connect('edited') do |*args|
 	    parent.cell_edited(*args.push(model))
 	end
    end
end

class ItemsGrid
    include Singleton
    COLUMN_NUMBER, COLUMN_PRODUCT, COLUMN_EDITABLE, NUM_COLUMNS = *(0..4).to_a

    def initialize
	@discount = 0
    end

    def glade=( glade )
	@grid = glade.get_widget("items_grid")

	@grid.model=Gtk::ListStore.new(String,String,String,String,Integer,String,String,String)
	@grid.rules_hint = true
	@grid.selection.mode = Gtk::SELECTION_SINGLE
 	@grid.headers_visible=true

	model = @grid.model

 	renderer = CellRender.new( self, model, 0 )
	renderer.editable=false
 	column = Gtk::TreeViewColumn.new("Item",renderer, {:text => 0})
 	column.min_width = 150
	@grid.append_column(column)

 	renderer = CellRender.new( self, model, 1 )
	column = Gtk::TreeViewColumn.new("Description",renderer,{:text => 1 } )
	column.min_width = 500
	@grid.append_column(column)

 	renderer = CellRender.new( self, model, 2 )
 	renderer.xalign = 0.5
	column = Gtk::TreeViewColumn.new("U/M",renderer,{:text => 2 } )
	column.min_width = 80
 	column.alignment = 0.5
	@grid.append_column(column)

	renderer = CellRender.new( self, model, 3 )
  	renderer.xalign = 1
	column = Gtk::TreeViewColumn.new("Price",renderer,{:text => 3 } )
	column.min_width = 100
	column.alignment = 1
	@grid.append_column(column)

	renderer = CellRender.new( self, model, 4 )
  	renderer.xalign = 0.5
	column = Gtk::TreeViewColumn.new("Qty",renderer,{:text => 4 } )
	column.min_width = 80
 	column.alignment = 0.5
	@grid.append_column(column)

 	renderer = Gtk::CellRendererText.new
 	renderer.editable=false
 	renderer.xalign = 1
	column = Gtk::TreeViewColumn.new("Total",renderer,{:text => 5 } )
 	column.alignment = 1
	column.min_width = 100
	@grid.append_column(column)

    end


    def new_sale( sale )
	@sale = sale
	clear
    end

    def focus
	if ! @grid.model.iter_first
	    FindItemsCtrl.instance.focus
	    true
	else
	    @grid.grab_focus
	end
    end

    def grid_got_focus( widget, dir )
	if ! @grid.model.iter_first
	    FindItemsCtrl.instance.focus
	    true
	else
	    false
	end
    end

    def skus
	skus = Array.new
	iter = @grid.model.iter_first
 	if iter
	    skus.push( create_sku( iter ) )
 	    while iter.next!
 		skus.push( create_sku( iter ) )
 	    end
 	end
	skus
    end

    def discount=( percent )
	if ( 0 != @discount ) && ( 0 == percent )

	    @grid.get_column(0).min_width = 150
	    @grid.get_column(1).min_width = 500

	    @grid.remove_column( @grid.get_column(7) )
	    @grid.remove_column( @grid.get_column(6) )

	    @discount = 0
	elsif 0 == @discount 
	    @discount = percent

	    @grid.get_column(0).min_width = 100
	    @grid.get_column(1).min_width = 400
	    
	    renderer = CellRender.new( self, @grid.model, 6 )
	    renderer.xalign = 0.5
	    column = Gtk::TreeViewColumn.new("Disc",renderer,{:text => 6 } )
	    column.min_width = 50
	    column.alignment = 0.5
	    @grid.append_column( column )

	    renderer = CellRender.new( self, @grid.model, 7 )
	    renderer.xalign = 1
	    renderer.editable=false
	    column = Gtk::TreeViewColumn.new("Disc Total",renderer,{:text => 7 } )
	    column.min_width = 100
	    column.alignment = 1
	    @grid.append_column( column )

	    update_discount( percent )
	else
	    update_discount( percent )
	end

    end

    def update_discount( perc )
	iter = @grid.model.iter_first
 	if iter
	    iter[6] = perc.to_s + '%'
	    update_row( iter )
 	    while iter.next!
		iter[6] = perc.to_s + '%'
		update_row( iter )
 	    end
 	end
    end


    def create_sku( iter )
	sku = INV::SaleSKU.new
	sku.code = iter[0]
	sku.descrip = iter[1]
	sku.um = iter[2]
	sku.qty = iter[4].to_i
	if 0 == @discount
	    sku.price = iter[3].to_f
	else
	    sku.price = iter[ 7 ].to_f
	    sku.discount = iter[ 5 ].to_f - iter[ 7 ].to_f
	end
	sku
    end

    def on_key_press_event( widget, k )
	key = k.keyval
puts key
	if 65535 == key
	    @grid.model.remove( @grid.selection.selected )
	    @sale.update
	end
    end


    def empty?
	if @grid.model.iter_first
	    false
	else
	    true
	end
    end

    def clear
	@grid.model.clear
    end

    def insert( sku )
	if sku.is_a? Array
	    for s in sku
		insert_sku( s )
	    end
	else
	    insert_sku( sku )
	end
    end


    def insert_sku( sku )
	line = @grid.model.prepend
	line[0] = sku.code
	line[1] = sku.descrip
 	line[2] = sku.um
 	line[3] = sprintf( '%0.2f',sku.price1 )
 	line[4] = 1
	line[6] = @discount.to_s + '%' if 0 != @discount 
	update_row( line )
    end
    private :insert_sku


    def update_row( row )
	row[5] = sprintf( '%0.2f',( row[4].to_i * row[3].to_f ) )
	if 0 != @discount
	    row[ 7 ] = sprintf( '%0.2f',( row[5].to_f * ( ( 100 - row[6].to_f ) / 100 ) ) )
	end
    end


    def cell_edited(cell, path_string, new_text, model)

	row = model.get_iter(Gtk::TreePath.new(path_string))
	case cell.column
	when 3
	    row[3] =  sprintf( '%0.2f', new_text.to_f )
	when 4
	    row[4] = new_text.to_i
	when 6
	    row[6] = new_text.to_i.to_s + '%'
	else
	    row[ cell.column ] = new_text
	end
	update_row( row )

	@sale.update
	FindItemsCtrl.instance.focus
    end
end
