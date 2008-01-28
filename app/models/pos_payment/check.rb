module PosPayment

    class Check < Base

        set_default_customer  Customer.find_by_code( DEF::ACCOUNTS['POS_CHECK'] )
        set_needs 'Telecheck Transaction #'

        validates_length_of :data,:minimum=>3, :message=>'Valid Telecheck or Check # not entered'


    end # Check

end
