

class PosPaymentType

    class CreditCardTerminal < PosPaymentType


        def customer
            Customer.find_by_code( DEF::ACCOUNTS['POS_CREDIT_CARD'] )
        end

        def error_msg
            self.data.first.empty? ? 'Valid Credit Card Processing Transaction # not entered' : ''
        end

        def transaction
            self.data.first
        end

        def needs
            Array[ 'Credit Card Processing Transaction #' ]
        end

    end # CreditCardTerminal

end
