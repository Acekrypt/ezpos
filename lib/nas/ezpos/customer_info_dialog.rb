

module NAS

module EZPOS

class CustomerInfoDialog < Gtk::Dialog


    def initialize( customer )

        super()

        self.title = "Customer ID: #{customer.customer_id}"

        self.default_response=Gtk::Dialog::RESPONSE_OK

        self.modal = true

        label = Gtk::Label.new( "Information for #{customer.customer_name}" )
        vbox.pack_start( label, false )

        if customer.credit_hold?
            label = Gtk::Label.new
            label.markup= '<span weight="bold" foreground="red" size="large">NO CREDIT SALES!</span>'
            vbox.pack_start( label, false )
            label = Gtk::Label.new
            label.markup= "<span weight=\"bold\" foreground=\"red\" size=\"medium\">(#{customer.credit_hold_explanation})</span>"
            vbox.pack_start( label, false )
        end

        table=Gtk::Table.new( 3, 2 )
        y=0
        [ 'mail_address1','mail_address2','mail_city','mail_postal_code','central_phone_number' ].each do | el |

            lab=Gtk::Label.new( el.capitalize )
            lab.set_alignment( 0,0.5 )
            table.attach( lab, 0, 1, y, y+1 )
            lab=Gtk::Label.new( customer.method( el ).call.to_s )
            lab.set_alignment( 0,0.5 )
            table.attach( lab, 1, 2, y, y+=1 )
        end

        vbox.pack_start( table, true )

        self.add_button( Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL )

        btn=self.add_button( Gtk::Stock::OK, Gtk::Dialog::RESPONSE_OK )
        btn.grab_default
        @ok=false
        signal_connect("response") do |widget, response|
            @ok=( response == Gtk::Dialog::RESPONSE_OK )
            self.destroy
        end
        self.show_all
        self.run
    end

    def ok?
        @ok
    end
end


end # POS

end # NAS
