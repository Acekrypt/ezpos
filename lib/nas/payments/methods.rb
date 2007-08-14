
module NAS

module Payments

module Methods

class CreditCard
    attr_reader :id, :name, :needs, :open_drawer

    def initialize
	@id = 1
	@name = 'Credit Card'
	@needs = Array['Credit Card Processing Transaction #' ]
	@open_drawer = false
    end

    def customer( elements )
	Customer.find_by_code( DEF::ACCOUNTS['POS_CREDIT_CARD'] )
    end

    def validate( elements )
	if ( ! elements.empty? ) && ( ! elements.first.empty? )
	    ''
	else
	    'Valid Credit Card Processing Transaction # not entered'
	end
    end

    def transaction_id(elements)
	elements.first
    end

end

class CreditCardTerminal < CreditCard

end

class CreditCardProcess
    attr_reader :id, :name, :needs, :open_drawer

    def initialize
	@id = 1
	@name = 'Credit Card'
	@needs = Array['Credit Card #','Expiration Month','Expiration Year' ]
        @open_drawer = false
    end

    def customer( elements )
	Customer.find_by_code( DEF::ACCOUNTS['POS_CREDIT_CARD'] )
    end

    def validate( elements )
	if ( ! elements.empty? ) && ( ! elements.first.empty? )
	    ''
	else
	    'Valid Credit Card Processing Transaction # not entered'
	end
    end

    def transaction_id(elements)
	elements.first
    end

end



class Cash
    attr_reader :id, :name, :needs, :open_drawer

    def initialize
	@id = 2
	@name = 'Cash'
	@needs = Array[ ]
	@open_drawer = true
    end

    def validate( elements )
	''
    end

    def transaction_id(elements)
	''
    end

    def customer( elements )
        puts "CASH: #{DEF::ACCOUNTS['POS_CASH']}"
        Customer.find_by_code( DEF::ACCOUNTS['POS_CASH'] )
    end
end


class Check
    attr_reader :id, :name, :needs, :open_drawer
    def initialize
	@id = 3
	@name = 'Check'
	@open_drawer = true
	@needs = Array[ 'Telecheck Transaction #' ]
    end

    def validate( elements )
	if ( ! elements.empty? ) && ( ! elements.first.empty? )
	    ''
	else
	    'Valid Telecheck Transaction # not entered'
	end
    end

    def transaction_id(elements)
	elements.first
    end

    def customer( elements )
        Customer.find_by_code( DEF::ACCOUNTS['POS_CHECK'] )
    end

end



class BillingAcct
    attr_reader :id, :name, :needs, :open_drawer

    def initialize
	@id = 4
	@open_drawer = false
	@name = 'Billing Account'
	@needs = Array[ 'Customer Code' ]
    end


    def customer( elements )
	Customer.find_by_code( elements.first )
    end

    def transaction_id(elements)
	''
    end

    def validate( elements )
	if ( elements.empty? ) || ( elements.first.empty? )
            return 'Customer Code not entered'
        else
            @cc=Customer.find_by_code( elements.first )
            if @cc.nil?
                return "Customer code #{elements.first} does not exist"
            else
                return ''
            end
        end
    end

end



class GiftCertificate
    attr_reader :id, :name, :needs, :open_drawer

    def initialize
	@id = 5
	@open_drawer = false
	@name = 'Gift Certificate'
	@needs = Array[ 'Certificate Code' ]
    end

    def customer( elements )
        Customer.find_by_code( DEF::ACCOUNTS['POS_GIFT_CERT'] )
    end

    def transaction_id(elements)
	elements.first
    end

    def validate( elements )
	if ( ! elements.empty? ) && ( ! elements.first.empty? )
	    ''
	else
	    'Gift certificate code not given'
	end
    end

end



   ALL = Array[
               CreditCard.new,
               Cash.new,
               Check.new,
               BillingAcct.new,
               GiftCertificate.new,
    ]

    NON_CREDIT_CARD = Array[
                            Cash.new,
                            Check.new,
                            BillingAcct.new,
                            GiftCertificate.new,
                           ]

    CC_PROCCESS=CreditCardProcess.new
    CC_TERMINAL=CreditCardTerminal.new

    def Methods.all
        ALL
    end

    def Methods.non_credit_card
        NON_CREDIT_CARD
    end

    def Methods.find( key )
        if key.is_a? Numeric
            method_name = "id"
        else
            method_name = "name"
        end
        for obj in ALL
            aMethod = obj.method( method_name )
            return obj if aMethod.call == key
        end
        nil
    end



end # module Methods

end # module Payment

end # module NAS

