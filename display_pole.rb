require 'singleton'
require 'local_config'
require 'logic_controls'

class DisplayPole

    include Singleton


    def initialize
	@pole=LogicControlsDisplay.new( LocalConfig::DISPLAY_POLE_PORT )
    end

    def show_sale( sale )
	@pole.line_one=sprintf('Sb %10s Tx %8s',sale.subtotal.to_s, sale.tax.to_s )
	@pole.line_two=sprintf('Total: %15s', sale.total.to_s)
    end


    def show_sku( sku , sale_total )
	@pole.line_one=sku.descrip[0..LogicControlsDisplay::LINE_LENGTH]
	@pole.line_two=sprintf('%-9s Tot %11s',sku.total.to_s, sale_total.to_s)
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
