module NAS

module EZPOS

class SaleToolbar < Gtk::Toolbar

    def initialize( sale )
        super()
        @sale=sale

        if DEF::POS_PROCESS_CARDS
                @proc_credit_cards=Gtk::CheckButton.new('C-Cards?')
                @proc_credit_cards.active=Settings['proccess_credit_cards']
                @proc_credit_cards.signal_connect('toggled'){ | widget | Settings['proccess_credit_cards'] = widget.active? }
                self.append( @proc_credit_cards )
                self.append_space
        else
                Settings['proccess_credit_cards']=false
        end

        @rep=Gtk::Entry.new
        @rep.width_chars=5
        self.append( Gtk::Label.new('Rep:') )
        self.append( @rep, "Rep", nil )

        self.append_space

        @discount=Gtk::SpinButton.new(0,99,5)
        @discount.signal_connect('value_changed'){ @sale.update_discount }

        self.append( Gtk::Label.new('Discount:') )
        self.append( @discount, "Discount", nil )

        self.append_space

        @tax_toggle=Gtk::CheckButton.new('Tax Exempt')
        @tax_toggle.signal_connect('toggled'){ | widget | @sale.update_tax }
        self.append( @tax_toggle )

        self.append_space

        self.append( "P21", "Open Prophet 21" ) {
                `rdesktop -f p21.allmed.net`
        }

        self.append_space

        self.append( "Open Drawer", "Open Cash Drawer" ) {
                CashDrawer.open
        }

        self.append_space

        self.append( "Abandon Sale", "abort sale, starting over." ) {
            sale.reset
        }

        self.append_space

        self.append( "Finalize Sale", "complete Sale by entering payment" ) {
            sale.finalize
        }
        f12k = Gtk::AccelGroup.new
        f12k.connect( Gdk::Keyval.const_get( "GDK_F12".to_sym),nil, Gtk::ACCEL_VISIBLE ) {
                sale.finalize
        }
        #self.add_accel_group( f12k )

    end

    def begin_new_sale
        @rep.text=""
    end

    def focus_rep
        @rep.grab_focus
    end

    def rep
        @rep.text
    end

    def process_credit_cards?
        @proc_credit_cards.active?
    end

    def tax_exempt?
        @tax_toggle.active?
    end

    def discount
        @discount.value
    end

end # SaleToolbar

end # EZPOS

end # NAS
