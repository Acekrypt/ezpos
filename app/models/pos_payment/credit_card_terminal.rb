module PosPayment

    class CreditCardTerminal < Base

        set_default_customer  Customer.find_by_code( DEF::ACCOUNTS['POS_CREDIT_CARD'] )
        set_needs 'Credit Card Processing Transaction #'

        validates_length_of :data, :minimum=>3, :message=>'Valid Credit Card Processing Transaction # not entered'

    end

end
