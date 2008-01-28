module PosPayment

    class Cash < Base

        set_default_customer Customer.find_by_code( DEF::ACCOUNTS['POS_CASH'] )

    end

end
