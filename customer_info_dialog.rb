


class CustomerInfoDialog

    
    def initialize( glade, customer )
	@dialog = glade.get_widget('customer_info_dialog')
	@dialog.hide
	@dialog.window_position=Gtk::Window::POS_CENTER_ALWAYS
	@dialog.default_response=Gtk::Dialog::RESPONSE_OK
	for str in ['company','name','address1','address2','city','zip','phone','comments']
	    markup( glade.get_widget('cust_info_' + str + '_label'), customer.method( str ).call )
	end

	if customer.acct_balance <= customer.credit_limit
	    txt = 'OK'
	else
	    txt = '<span weight="bold" foreground="red">OVER LIMIT</span>'
	end
	glade.get_widget('cust_info_credit_ok_label').markup=txt


	if customer.taxrate == 0
	    txt = 'Yes'
	else
	    txt = '<span weight="bold" foreground="red">No</span>'
	end
	glade.get_widget('cust_info_tax_exempt_label').markup=txt
    end

    def sale_ok?
	ret = ( @dialog.run == Gtk::Dialog::RESPONSE_OK )
	@dialog.hide
	ret
    end

    def markup( ctrl, str )
	ctrl.set_markup( str )
    end

end
