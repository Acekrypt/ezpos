require 'customer'

class PosPaymentType

    class Cash < PosPaymentType

        def should_open_drawer?
            true
        end

        def customer
            Customer.find_by_code( DEF::ACCOUNTS['POS_CASH'] )
        end

        def error_msg
            ''
        end

        def transaction
            ''
        end

        def needs
            Array.new
        end

    end # Cash


end
