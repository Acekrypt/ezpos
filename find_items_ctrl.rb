

require 'singleton'
require 'nas/inv/sku.rb'

class FindItemsCtrl
    include Singleton

    def initialize
	@db = NAS::DB.instance
    end

    attr_accessor :entry

    def glade=( glade )

	@grid = glade.get_widget("found_skus_results_grid")
	@entry = glade.get_widget("find_sku_entry_box")

	column = Gtk::TreeViewColumn.new("Item",Gtk::CellRendererText.new, {:text => 0 })
	column.min_width = 150
	@grid.append_column(column)

	column = Gtk::TreeViewColumn.new("Description", Gtk::CellRendererText.new,{:text => 1} )
	column.min_width = 300
	@grid.append_column(column)


	@grid_items = Gtk::ListStore.new(String, String)

	@grid.model = @grid_items
    end


    def entry_complete( widget )
	@sale.add
    end

    def clear
	@grid_items.clear
	@entry.text = ""
	@entry.grab_focus
    end

    def new_sale( sale )
	@sale = sale
	clear
    end

    def grid_cursor( widget )
	@entry.text = @grid.model.get_value( @grid.selection.selected, 0 )
    end

    def select(widget, path, treeview )
	@sale.add
    end

    def focus
	@entry.grab_focus
    end

    def grid_got_focus( widget, dir )
	if ! @grid.model.iter_first
#	    ItemsGrid.instance.focus
	    true
	else
	    false
	end
    end

    def code
	@entry.text.upcase
    end

    def nearest_match
	iter = @grid.model.iter_first
	if iter
	    iter[0].upcase
	else
	    nil
	end
    end

    def update( widget, key )
	char = Gdk::Keyval.to_name( key.keyval )
	char.delete!( 'KP_' )
	if 1 == char.size
	    char = char[0]
	    if char > 47 && char < 123
		@grid_items.clear
		sql = 'select code, descrip from sku where code like \'' + (widget.text + sprintf('%c',char)).upcase + '%\' limit 100'
		res = @db.exec( sql )
		res.result.each do |tupl|
		    line = @grid_items.append
		    line[0] = tupl[0]
		    line[1] = tupl[1]
		end
	    end
	else if 'BackSpace' == char
		 @grid_items.clear
		 if widget.text.size > 1
		     sql = 'select code, descrip from sku where code like \'' + widget.text.chop + '%\' limit 100'
		     res = @db.exec( sql )
		     res.result.each do |tupl|
			line = @grid_items.append
			line[0] = tupl[0]
			line[1] = tupl[1]
		    end
		 end
	     end
	end
	false
    end
end
