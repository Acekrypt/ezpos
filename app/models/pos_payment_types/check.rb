

class PosPaymentType

    class Check < PosPaymentType


        def customer
            Customer.find_by_code( DEF::ACCOUNTS['POS_CHECK'] )
        end

        def error_msg
            self.data.first.empty? ? 'Valid Telecheck or Check # not entered' : ''
        end

        def transaction
            self.data.first
        end

        def needs
            Array['Telecheck Transaction #']
        end

    end # Check

end
