require 'pos_payment_type'


module NAS

module EZPOS

class SalesSummary

    attr_reader :begining, :ending, :sales, :returns

    def initialize( begining, ending=nil )
        ( @begining, @ending ) = [ begining, ending ]
        if single_day?
            @sales   = PosSale.find_on_date( begining )
            @rec     = PosDailyReceipt.find_by_day( begining )
            @returns = PosSaleSkuReturn.find_on_date( begining )
        else
            @sales   = PosSale.find_between_dates( begining, ending )
            @rec     = PosDailyReceipt.find_between_dates( begining, ending )
            @returns = PosSaleSkuReturn.find_between_dates( begining, ending )
            @ending = ending
        end
        @sales = sales
    end

    def have_receipts?
        if single_day?
            return ( ! @rec.nil? )
        else
            return ( ! @rec.empty? )
        end
    end

    def get_receipts( type )
        return Money.new unless have_receipts?
        if single_day?
            return @rec.method( type ).call
        else
            ret=Money.new
            @rec.each do | rec |
                ret+=rec.method( type ).call
            end
            return ret
        end
    end

    def check_receipts
        get_receipts( 'checks' )
    end

    def cash_receipts
        get_receipts( 'cash' )
    end

    def billing_receipts
        get_receipts( 'billing' )
    end

    def return_receipts
        get_receipts( 'returns' )
    end

    def credit_card_receipts
        get_receipts( 'credit_cards' )
    end

    def total_receipts
        credit_card_receipts + cash_receipts + check_receipts
    end

    def date_str
        if single_day?
            @begining.strftime('%d %b, %Y')
        else
            "#{@begining.strftime('%d %b, %Y')} - #{@ending.strftime('%d %b, %Y')}"
        end
    end

    def total_sales
        total-returned_total
    end

    def single_day?
        @ending.nil?
    end

    def add_sale( sale )
        @sales.push(sale)
    end

    def returned_total
        total = Money.new
        @sales.each do | sale |
            total += sale.total_returned
        end
        total
    end

   def returned_tax
        total = Money.new
        @sales.each do | sale |
            total += sale.total_tax_returned
        end
        total
    end

    def subtotal
        stotal = ::Money.new
        @sales.each do | sale |
            stotal += sale.subtotal
        end
        stotal
    end

    def total
        self.subtotal + self.tax_collected
    end

    def tax_collected
        stax = Money.new
        @sales.each do | sale |
            stax += sale.tax
        end
        stax
    end

    def amount_of_type( type )
        total = Money.new
        @sales.each do | sale |
            for payment in sale.payments
                total += payment.amount if payment.payment_type == type
            end
        end
        total
    end

    def total_checks
        amount_of_type PosPaymentType::CHECK
    end

    def total_cash
        ret = amount_of_type PosPaymentType::CASH
        @sales.each do | sale |
            ret -= sale.change_given
        end
        ret
    end

    def total_credit_cards
        amount_of_type( PosPaymentType::CREDIT_CARD ) + amount_of_type( PosPaymentType::CC_TERMINAL )
    end


    def total_billing
        amount_of_type( PosPaymentType::BILLING )
    end

    def total_gift_cert
        amount_of_type( PosPaymentType::GIFT_CERT )
    end
end

end # EZPOS

end # NAS
