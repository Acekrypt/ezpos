require 'singleton'
require 'nas/local_config'
require 'nas/display_pole/LCDisplayPole'

class DisplayPole

    include Singleton


    def initialize
	@pole=LCDisplayPole.new( NAS::LocalConfig::DISPLAY_POLE_PORT )
    end

    def reset
	@pole.reset
    end

    def show_sale( sale )
	@pole.line_one=sprintf('Sb %10s Tx %8s',sale.subtotal.pretty_s, sale.tax.pretty_s )
	@pole.line_two=sprintf('Total: %15s', sale.total.pretty_s)
    end


    def show_sku( sku , sale_total )
	@pole.line_one=sku.descrip[0..LCDisplayPole::LINE_LENGTH]
	@pole.line_two=sprintf('%-9s Tot %11s',sku.total.pretty_s, sale_total.pretty_s)
    end

    def show_thanks
	@pole.line_one=POS::Setting.instance.pole_thank_you_one.center( LCDisplayPole::LINE_LENGTH )
	@pole.line_two=POS::Setting.instance.pole_thank_you_two.center( LCDisplayPole::LINE_LENGTH )
    end

    def show_welcome
	@pole.line_one=POS::Setting.instance.pole_welcome_one.center( LCDisplayPole::LINE_LENGTH )
	@pole.line_two=POS::Setting.instance.pole_welcome_two.center( LCDisplayPole::LINE_LENGTH )
    end
end
