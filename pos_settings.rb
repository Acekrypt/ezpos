require 'gconf2'
require 'singleton'

module POS

class Setting
    BAD_CC_SWIPE = ';E/'
    include Singleton

    attr_accessor :tax_exempt
    attr_reader  :tax_rate, :print_header, :drawer_char, :pole_thank_you_pause, :pole_thank_you_one, :pole_thank_you_two, :pole_welcome_pause, :pole_welcome_one, :pole_welcome_two, :process_cards


    def initialize
	@gConf = GConf::Client.new
	@tax_rate = @gConf['/apps/ezpos/tax_rate']
	@print_header =	@gConf['/apps/ezpos/print_header']
	@print_header = '' if ! @print_header
	@tax_rate=0.0 if ! @tax_rate
	@tax_exempt = false;
	if ! @gConf.dir_exists?( '/apps/ezpos' )
	    @gConf['/apps/ezpos/pole_welcome_pause'] =  @gConf['/apps/ezpos/pole_thank_you_pause'] = 10
	    @gConf['/apps/ezpos/pole_welcome_one'] = @gConf['/apps/ezpos/pole_welcome_two'] = @gConf['/apps/ezpos/pole_thank_you_one'] = @gConf['/apps/ezpos/pole_thank_you_two'] = ''
	    @gConf['/apps/ezpos/proccess_credit_cards']=false
	end

	@pole_welcome_pause=@gConf['/apps/ezpos/pole_welcome_pause'].to_i
	@pole_welcome_one=@gConf['/apps/ezpos/pole_welcome_one']
	@pole_welcome_two=@gConf['/apps/ezpos/pole_welcome_two']

	@pole_thank_you_pause=@gConf['/apps/ezpos/pole_thank_you_pause'].to_i
	@pole_thank_you_one=@gConf['/apps/ezpos/pole_thank_you_one']
	@pole_thank_you_two=@gConf['/apps/ezpos/pole_thank_you_two']
	@process_cards=@gConf['/apps/ezpos/proccess_credit_cards']
puts @process_cards
	@drawer_char=7
    end

    def toggle_proccess_cards
puts 'Cards Toggled'
puts caller
	@process_cards = ! @process_cards
	@gConf['/apps/ezpos/proccess_credit_cards']=@process_cards
    end

    def tax_rate=( tax )
	@gConf['/apps/ezpos/tax_rate'] = tax
	@tax_rate = tax
	TotalsDisplay.instance.update
    end
    
    def set_not_tax_exempt
	@tax_exempt = false
    end

    def toggle_tax_exempt
	@tax_exempt = ! @tax_exempt
    end

    def print_header=( ph )
	@gConf['/apps/ezpos/print_header'] = ph
	@print_header = ph
    end
 
    def drawer_char
	7
    end

    def pole_welcome_pause=(msg)
	@gConf['/apps/ezpos/pole_welcome_pause'] = @pole_welcome_pause=msg
    end


    def pole_welcome_one=(msg)
	@gConf['/apps/ezpos/pole_welcome_one'] = @pole_welcome_one=msg
    end

    def pole_welcome_two=(msg)
	@gConf['/apps/ezpos/pole_welcome_two'] = @pole_welcome_two=msg
    end

    def pole_thank_you_pause=(msg)
	@gConf['/apps/ezpos/pole_thank_you_pause'] = @pole_thank_you_pause=msg
    end

    def pole_thank_you_one=(msg)
	@gConf['/apps/ezpos/pole_thank_you_one'] = @pole_thank_you_one=msg
    end

    def pole_thank_you_two=(msg)
	@gConf['/apps/ezpos/pole_thank_you_two'] = @pole_thank_you_two=msg
    end


end
end
