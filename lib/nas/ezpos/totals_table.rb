
module NAS

module EZPOS

class TotalsTable < Gtk::Table
    MARKUP = '<span weight="bold" font_family="Times" foreground="red" size="xx-large"'

    def initialize( parent )
        super( 3, 2 )
        @parent_widget=parent

        @labels=Array.new

        self.attach( create_label('Sub Total:'), 0, 1, 0, 1 )
        @sub_total_amount=create_label('0.00')
        @sub_total_amount.xalign=1
        self.attach( @sub_total_amount, 1, 2, 0, 1 )

        @tax_label=create_label('Tax:')
        self.attach( @tax_label, 0, 1, 1, 2 )
        @tax_amount=create_label('0.00')
        @tax_amount.xalign=1
        self.attach( @tax_amount, 1, 2, 1, 2 )

        self.attach( create_label('Total:'), 0, 1, 2, 3 )
        @total_amount=create_label('0.00')
        @total_amount.xalign=1
        self.attach( @total_amount, 1, 2, 2, 3 )
    end


    def sale=( sale )
        @sale=sale
        self.update
    end

    def update
        @tax_label.markup="#{MARKUP} strikethrough=\"#{@parent_widget.tax_exempt?.to_s}\">Tax:</span>"
        if @parent_widget.tax_exempt?
            @tax_amount.markup="#{MARKUP} strikethrough=\"true\">0.00</span>"
            @tax_label.markup="#{MARKUP} strikethrough=\"true\">Tax:</span>"
        else
            @tax_amount.markup="#{MARKUP}>#{@sale.tax.format}</span>"
            @tax_label.markup="#{MARKUP}>Tax:</span>"
        end
        @sub_total_amount.markup="#{MARKUP}>#{@sale.subtotal.format}</span>"
        @total_amount.markup="#{MARKUP}>#{@sale.total.format}</span>"
    end

    def create_label(text)
        label=Gtk::Label.new
        label.markup="#{MARKUP}>#{text}</span>"
        label.xalign=0
        @labels.push( label )
        return label
    end




end # Totals

end # EZPOS

end # NAS
