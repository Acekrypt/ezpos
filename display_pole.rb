require 'singleton'

require 'logic_controls'

class DisplayPole

    include Singleton


    def initialize
	@pole=LogicControlsDisplay.new('/dev/ttyS0')
    end

    def show_sale( sale )
	@pole.line_one=sprintf('Sb %7.2f Tx %5.2f',sale.subtotal, sale.tax )
	@pole.line_two=sprintf('Total: %12.2f', sale.total)
    end


    def show_sku( sku , sale_total )
	@pole.line_one=sku.descrip[0..LogicControlsDisplay::LINE_LENGTH]
	@pole.line_two=sprintf('%-6.2f Tot %8.2f',sku.total, sale_total)
    end

    def show_thanks
	@pole.line_one=POS::Setting.instance.pole_thank_you_one.center( LogicControlsDisplay::LINE_LENGTH )
	@pole.line_two=POS::Setting.instance.pole_thank_you_two.center( LogicControlsDisplay::LINE_LENGTH )
    end

    def show_welcome
	@pole.line_one=POS::Setting.instance.pole_welcome_one.center( LogicControlsDisplay::LINE_LENGTH )
	@pole.line_two=POS::Setting.instance.pole_welcome_two.center( LogicControlsDisplay::LINE_LENGTH )
    end
end
