

require 'singleton'
require 'inv/sku.rb'


class CellRender < Gtk::CellRendererText
    attr_accessor :column
    def initialize( parent,model,column )
	super()
	@column = column
	self.editable = parent.editable?
	self.background = "pink"
	signal_connect('edited') do |*args|
 	    parent.cell_edited(*args.push(model))
 	end

    end

end




class ItemsGrid

    SKU_ELEMENT=8
    BACKGROUND_ELEMENT = 9
    def init( grid, first_name, pixbuf )
	@grid = grid
	@discount = 0



	@grid.model=Gtk::ListStore.new(String,String,String,String,Integer,String,String,String,INV::SaleSKU, TrueClass )
	@grid.rules_hint = true
	@grid.selection.mode = Gtk::SELECTION_SINGLE
 	@grid.headers_visible=true

	model = @grid.model

 	renderer = Gtk::CellRendererPixbuf.new
	@grid.signal_connect('row_activated') do | view,row_num,col,store |
	    if 20 == col.min_width
		remove(  @grid.model.get_iter( @grid.selection.selected.path ) )
	    else
		selected( @grid.model.get_iter( @grid.selection.selected.path ) )
	    end
	    release_focus
 	end

	renderer.pixbuf=pixbuf
 	column = Gtk::TreeViewColumn.new(first_name,renderer )
 	column.min_width = 20
	@grid.append_column(column)

 	renderer = CellRender.new( self, model, 0 )
	renderer.editable=false
 	column = Gtk::TreeViewColumn.new("Item",renderer, {:text => 0, :background_set => 9})
 	column.max_width = column.min_width = 100
	@grid.append_column(column)

 	renderer = CellRender.new( self, model, 1 )
	column = Gtk::TreeViewColumn.new("Description",renderer,{:text => 1, :background_set => 9 } )
	column.max_width = column.min_width = 360
	@grid.append_column(column)

 	renderer = CellRender.new( self, model, 2 )
 	renderer.xalign = 0.5
	column = Gtk::TreeViewColumn.new("U/M",renderer,{:text => 2, :background_set => 9 } )
	column.max_width = column.min_width = 80
 	column.alignment = 0.5
	@grid.append_column(column)

	renderer = CellRender.new( self, model, 3 )
  	renderer.xalign = 1
	column = Gtk::TreeViewColumn.new("Price",renderer,{:text => 3, :background_set => 9 } )
	column.max_width = column.min_width = 100
	column.alignment = 1
	@grid.append_column(column)

	renderer = CellRender.new( self, model, 4 )
  	renderer.xalign = 0.5
	column = Gtk::TreeViewColumn.new("Qty",renderer,{:text => 4, :background_set => 9 } )
	column.max_width = column.min_width = 80
 	column.alignment = 0.5
	@grid.append_column(column)

 	renderer =  CellRender.new( self, model, 5 )
 	renderer.editable=false
 	renderer.xalign = 1
	column = Gtk::TreeViewColumn.new("List Price",renderer,{:text => 5, :background_set => 9 } )
 	column.alignment = 1
	column.max_width = column.min_width = 100
	@grid.append_column(column)

	renderer = CellRender.new( self, @grid.model, 6 )
	renderer.xalign = 0.5
	column = Gtk::TreeViewColumn.new("Disc",renderer,{:text => 6, :background_set => 9 } )
	column.max_width = column.min_width = 50
	column.alignment = 0.5
	@grid.append_column( column )

	renderer = CellRender.new( self, @grid.model, 7 )
	renderer.xalign = 1
	renderer.editable=false
	column = Gtk::TreeViewColumn.new("Disc Total",renderer,{:text => 7, :background_set => 9 } )
	column.max_width = column.min_width = 100
	column.alignment = 1
	@grid.append_column( column )

    end

    def release_focus
	nil
    end

    def new_sale( sale )
	@sale = sale
	clear
    end

    def skus
	skus = Array.new
	iter = @grid.model.iter_first
 	if iter
	    skus.push( iter[ SKU_ELEMENT ] )
 	    while iter.next!
 		skus.push( iter[ SKU_ELEMENT ] )
 	    end
 	end
	skus
    end

    def discount=( percent )
	@discount = percent
	update_discount( percent )
    end

    def update_discount( perc )
	row = @grid.model.iter_first
 	if row
	    row[6] = perc.to_i.to_s + '%'
	    update_row( row )
 	    while row.next!
		row[6] = perc.to_i.to_s + '%'
		update_row( row )
 	    end
 	end
    end


    def create_sku( iter )
	sku = INV::SaleSKU.new( @sale )
	sku.code = iter[0]
	sku.descrip = iter[1]
	sku.um = iter[2]
	sku.price = iter[3].to_f
	sku.qty = iter[4].to_i
	sku.discount = iter[6].to_i
	sku
    end

    def remove_row( iter ) 
	@grid.model.remove( iter )
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
	line[3] = sku.formated_price
	line[4] = sku.qty
	line[5] = sku.formated_undiscounted_total
	line[6] = get_discount( sku )
	line[7] = sku.formated_total
	line[8] = sku
	line[9] = sku.returned?
    end
    private :insert_sku

    def get_discount( sku )
	sku.formated_discount
    end

    def update_row( row )
	row[ 5 ] = sprintf( '%0.2f',( row[4].to_i * row[3].to_f ) )
	row[ 7 ] = sprintf( '%0.2f',( row[5].to_f * ( ( 100 - row[6].to_f ).to_f / 100 ) ) )
	row[ SKU_ELEMENT ] = create_sku( row )
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
	row[ SKU_ELEMENT ] = create_sku( row )
	update_row( row )
	
	@sale.update
    end

end


class SaleItemsGrid < ItemsGrid
    include Singleton
    
    def glade=( glade )
	init( glade.get_widget('items_grid'), 'Del',Gdk::Pixbuf.new( 'del.png' ) )
    end

    def focus
	if ! @grid.model.iter_first
	    FindItemsCtrl.instance.focus
	    true
	else
	    @grid.grab_focus
	end
    end

    def release_focus
	FindItemsCtrl.instance.focus
    end

    def get_discount( sku )
	sprintf('%i%%',DiscountCtrl.instance.value)
    end

    def grid_got_focus( widget, dir )
	if ! @grid.model.iter_first
	    FindItemsCtrl.instance.focus
	    true
	else
	    false
	end
    end

    def on_key_press_event( widget, k )
	key = k.keyval
	if 65535 == key
	    remove( @grid.selection.selected )
	end
    end


    def remove( iter )
	remove_row( iter )
	@sale.update
    end

    def selected( iter )
	# noop
    end

    def cell_edited(cell, path_string, new_text, model)
	super( cell,path_string,new_text,model)
	FindItemsCtrl.instance.focus
    end

    def editable?
	true
    end
    
end


class ViewItemGrid < ItemsGrid

    def initialize( tree_view, parent )
	init( tree_view, 'Ret', Gdk::Pixbuf.new( 'return.png' ) )
	@parent = parent
    end

    def editable?
	false
    end



    def on_key_press_event( widget, k )
	#noop
    end

    def cell_edited(cell, path_string, new_text, model)
	#noop
    end

   def remove( iter )
       @parent.remove_sku( iter )
    end

    def selected( iter )
	@parent.row_selected( iter )
    end
end
