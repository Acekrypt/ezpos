


class CustomerInfoDialog

    
    def initialize( glade, customer )
	dialog = glade.get_widget('customer_info_dialog')
	dialog.hide
	dialog.window_position=Gtk::Window::POS_CENTER_ALWAYS
	dialog.default_response=Gtk::Dialog::RESPONSE_OK
	for str in ['company','name','address1','address2','city','zip','phone']
	    markup( glade.get_widget('cust_info_' + str + '_label'), customer.method( str ).call )
	end

	dialog.signal_connect('response') do |widget, data|
	    widget.destroy
	end

	dialog.show
    end

    def markup( ctrl, str )
	ctrl.set_markup( str )
    end

end
