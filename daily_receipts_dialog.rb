
require 'nas/daily_receipts'
require 'singleton'

class DailyReceiptDialog
    include Singleton

    def glade=( glade )
	@dialog=glade.get_widget('daily_receipt_dialog')
	@checks_ctrl=glade.get_widget('daily_receipt_checks_box')
	@cash_ctrl = glade.get_widget('daily_receipt_cash_box')
	@credit_cards_ctrl=glade.get_widget('daily_receipt_credit_cards_box')
	@date_label = glade.get_widget('daily_receipt_date_label')

	glade.get_widget('daily_receipts_ok_button').signal_connect('clicked') do on_click_ok end
	glade.get_widget('daily_receipts_dialog_cancel_button').signal_connect('clicked') do on_click_cancel end
    end

    def show_receipts( date )
	now = Time.new
	if ( ( date.day == now.day ) && ( date.month == now.month ) && ( date.year == now.year ) ) 
	    set_editable( true )
	else
	    set_editable( false )
	end
	@receipts = NAS::DailyReceipt.find_on_date( date )
	if @receipts
	    set_to_receipt( @receipts )
	else
	    blank_fields
	end
	@dialog.present
    end
    
    def on_click_cancel
	@dialog.hide
    end

    def on_click_ok
	if @receipts
	    @receipts.checks = @checks_ctrl.text
	    @receipts.cash = @cash_ctrl.text
	    @receipts.credit_cards = @credit_cards_ctrl.text
	else
	    @receipts=NAS::DailyReceipt.new( Hash[ 
					   'date_covered' => Time.new,
					   'checks' => @checks_ctrl.text.to_f,
					   'cash'   => @cash_ctrl.text.to_f,
					   'credit_cards' => @credit_cards_ctrl.text.to_f,
				       ] )
	end
	@dialog.hide
    end
    
    def receipts
	@receipts
    end

    def set_to_receipt( receipt )
	@date_label.markup=receipt.date_covered.strftime('%m/%d/%Y')
	@checks_ctrl.text=receipt.checks.to_s
	@cash_ctrl.text=receipt.cash.to_s
	@credit_cards_ctrl.text=receipt.credit_cards.to_s
    end

    def blank_fields
	@date_label.markup=Time.new.strftime('%m/%d/%Y')
	@checks_ctrl.text='0.00'
	@cash_ctrl.text='0.00'
	@credit_cards_ctrl.text='0.00'
    end


    def set_editable( is_editable )
 	@checks_ctrl.sensitive=is_editable
 	@cash_ctrl.sensitive=is_editable
 	@credit_cards_ctrl.sensitive=is_editable
    end
end
