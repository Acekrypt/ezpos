require 'singleton'
require 'nas/inv/sale'
require 'pos_settings'

class DiscountCtrl
    include Singleton


    def glade=( glade )
	
	@ctrl = glade.get_widget('discount_spin_ctrl')

	@ctrl.signal_connect('value_changed') do
	    value_changed
	end
	


    end

    def value
	@ctrl.value
    end
    
    def value_changed
	SaleItemsGrid.instance.discount=@ctrl.value
	@sale.update
    end

    def clear
	@ctrl.value=0
	value_changed
    end

    def sale=( sale )
	@sale = sale
    end
end
