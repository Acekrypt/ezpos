module NAS

module EZPOS

class PaymentSelect < Gtk::Dialog
    MARKUP='<span weight="bold" foreground="red" size="large">'
    BAD_CC_SWIPE = ';E/'

    attr_reader :amount, :selected_type, :values

    def initialize( total, remaining )
        super()
        self.title = 'Select Payment Type/Amount'
        self.modal=true
        @types=Hash.new
        @current_boxes=Array.new
        @amount=BigDecimal.zero
        @transaction_id

        label = Gtk::Label.new
        if total == remaining
            label.markup="#{MARKUP}#{total.format}</span>"
        else
            label.markup="#{MARKUP}#{total.format} - #{(total-remaining).format} = #{remaining.format}</span>"
        end
        vbox.pack_start( label, false )

        self.default_response=Gtk::Dialog::RESPONSE_OK

        buttons=Gtk::HBox.new
        vbox.pack_start( buttons, false, false, 5 )

        group=Gtk::RadioButton.new
        num=1
        methods=PosPaymentType.non_credit_card.clone
        if Settings['proccess_credit_cards']
            methods << PosPaymentType::CREDIT_CARD
        else
            methods << PosPaymentType::CC_TERMINAL
        end
        methods.each do | pt |
            pt.data = nil
            button=Gtk::RadioButton.new( group,"F#{num}-#{pt.name}" )
            alt_s = Gtk::AccelGroup.new
            alt_s.connect( Gdk::Keyval.const_get( "GDK_F#{num}".to_sym),nil, Gtk::ACCEL_VISIBLE ) {
                button.activate
                self.set_inputs( pt )
            }
            @types[ pt ] = button
            self.add_accel_group( alt_s )
            num+=1
            buttons.add( button )
            button.signal_connect('clicked') do |button|
                self.set_inputs( pt )
            end
        end

        hbox=Gtk::HBox.new
        vbox.pack_start(hbox,false,false,5)
        hbox.pack_start( Gtk::Label.new( 'Amount: ' ),false )
        @amount_entry=Gtk::Entry.new
        @amount_entry.activates_default=true
        @amount_entry.text=remaining.money
        hbox.pack_start( @amount_entry,true,true )

        @ok=false

        self.add_button( Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL )

        btn=self.add_button( Gtk::Stock::OK, Gtk::Dialog::RESPONSE_OK )
        btn.grab_default

        signal_connect("response") do |widget, response|
            got_response( response )
        end
        show_all
        @selected_type=methods.first
        @types[ @selected_type ].activate
        self.run
    end

    def got_response( resp )
        err=''
        if ( @selected_type == PosPaymentType::CREDIT_CARD && custom_input_values.first == BAD_CC_SWIPE )
            Gdk::Display.default.beep
            @current_boxes.each{ |bx| bx.text="" }
        end
        @values=Array.new
        @amount=BigDecimal.zero

        if resp ==  Gtk::Dialog::RESPONSE_OK
            @selected_type.data=custom_input_values
            err=@selected_type.error_msg
            if err.empty?
                @ok=true
                @transaction_id=@selected_type.transaction
                @values.push( *custom_input_values )
                @amount=BigDecimal.new( @amount_entry.text )
                self.destroy
            else
                dialog = Gtk::MessageDialog.new( nil,Gtk::Dialog::MODAL,
                                                 Gtk::MessageDialog::ERROR,
                                                 Gtk::MessageDialog::BUTTONS_OK, err  )
                ret = ( dialog.run == Gtk::Dialog::RESPONSE_OK )
                dialog.destroy
                self.run
            end
        else
            @ok=false
            self.destroy
        end
    end

    def ok?
        @ok
    end

    def record( sale )
        pymt=PosPayment.new( Hash[
                                  'payment_type'=>@selected_type,
                                  'amount'=> @amount,
                                  'customer'=>@selected_type.customer,
                                  'transaction_id'=> @transaction_id,
                                  'sale'=> sale,
                              ] )
        pymt.save
        pymt
    end

    def transaction_id=( trans )
        @transaction_id = trans
    end

    def custom_input_values
        ret=Array.new
        @current_boxes.each{ | el | ret << el.last.text }
        ret
    end

    def set_inputs( pt )
        @selected_type=pt

        @current_boxes.each do | ( box, label, entry ) |
            self.vbox.remove( box )
        end
        @current_boxes.clear
        pt.needs.each do | needs |
            box=Gtk::HBox.new
            label=Gtk::Label.new( needs )
            entry=Gtk::Entry.new
            entry.activates_default=true
            @current_boxes <<  Array[ box, label, entry ]
            self.vbox.pack_start( box )
            box.pack_start( label,false )
            box.pack_start( entry,true,true,5 )
            box.show_all
        end
        need=@current_boxes.first
        need.last.grab_focus unless need.nil?
    end


end # PaymentSelect

end # EZPOS

end # NAS
