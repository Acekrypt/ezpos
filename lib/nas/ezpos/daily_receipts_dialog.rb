

module NAS

module EZPOS

class DailyReceiptsDialog < Gtk::Dialog
    MARKUP = '<span weight="bold" font_family="Times" size="large"'

    def initialize( date )
        @date=date

        @allow_edit=( @date == Date.today )

        @receipt=PosDailyReceipt.find_by_day( date )
        super()
        self.title = 'Receipts'
        self.default_response=Gtk::Dialog::RESPONSE_OK
        self.modal = true

        label = Gtk::Label.new( @date.strftime("Daily Recipts for %a, %m %b") )
        vbox.pack_start( label, false )

        table=Gtk::Table.new( 3, 2 )

        table.attach( create_label('Checks:'), 0, 1, 0, 1 )
        @checks=create_entry('checks')
        table.attach( @checks, 1, 2, 0, 1 )

        @tax_label=create_label('Cash:')
        table.attach( @tax_label, 0, 1, 1, 2 )
        @cash=create_entry('cash')
        table.attach( @cash, 1, 2, 1, 2 )

        table.attach( create_label('Credit Cards:'), 0, 1, 2, 3 )
        @credit_cards=create_entry('credit_cards')
        table.attach( @credit_cards, 1, 2, 2, 3 )

        table.attach( create_label('Billing Accts:'), 0, 1, 3, 4 )
        @billing=create_entry('billing')
        table.attach( @billing, 1, 2, 3, 4 )

        table.attach( create_label('Returns:'), 0, 1, 4, 5 )
        @returns=create_entry('returns')
        table.attach( @returns, 1, 2, 4, 5 )

        vbox.pack_start( table, true )

        self.add_button( Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL )

        btn=self.add_button( Gtk::Stock::OK, Gtk::Dialog::RESPONSE_OK )
        btn.grab_default

        signal_connect("response") do |widget, response|
            got_response( response )
        end
        self.show_all

    end

    def allow_edit?
        @allow_edit
    end

    def create_entry( name )
        ent=Gtk::Entry.new
        ent.editable=self.allow_edit?
        ent.text=@receipt.method(name).call.to_s if @receipt
        return ent
    end

    def create_label(text)
        label=Gtk::Label.new
        label.markup="#{MARKUP}>#{text}</span>"
        label.xalign=0
        return label
    end

    def got_response( resp )
        if resp == Gtk::Dialog::RESPONSE_OK
            unless @receipt
                @receipt = PosDailyReceipt.new
                @receipt.day=@date
            end
            @receipt.cash = Money.new(@cash.text.to_f*100)
            @receipt.checks = Money.new(@checks.text.to_f*100)
            @receipt.credit_cards = Money.new(@credit_cards.text.to_f*100)
            @receipt.billing = Money.new( @billing.text.to_f*100 )
            @receipt.returns = Money.new( @returns.text.to_f*100 )
            @receipt.save
        end
        self.destroy
    end


end # DailyReceiptsDialog

end # EZPOS

end # NAS
