require 'nas/ezpos/settings'
require 'nas/ezpos/display_pole/LCDisplayPole'

module NAS

module EZPOS

class DisplayPole

    def initialize( port )
	@pole=LCDisplayPole.new( port )
    end

    def reset
	@pole.reset
    end

    def show_sale( sale )
	@pole.line_one=sprintf('Sb %8s Tx %5s',sale.subtotal.format, sale.tax.format )
	@pole.line_two=sprintf('Total: %13s', sale.total.format)
    end

    def show_sku( sku , sale_total )
	@pole.line_one=sku.descrip[0..LCDisplayPole::LINE_LENGTH]
	@pole.line_two=sprintf('%-7s Tot %8s',sku.total.format, sale_total.format)
    end

    def show_thanks
	@pole.line_one=Settings['display_pole/thanks_line_one'].center( LCDisplayPole::LINE_LENGTH )
	@pole.line_two=Settings['display_pole/thanks_line_two'].center( LCDisplayPole::LINE_LENGTH )
    end

    def show_welcome
	@pole.line_one=Settings['display_pole/welcome_line_one'].center( LCDisplayPole::LINE_LENGTH )
	@pole.line_two=Settings['display_pole/welcome_line_two'].center( LCDisplayPole::LINE_LENGTH )
    end
end # DisplayPole

end # EZPOS

end # NAS