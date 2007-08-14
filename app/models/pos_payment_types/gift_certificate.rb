

class PosPaymentType

    class GiftCertificate < PosPaymentType


        def customer
            Customer.find_by_code( DEF::ACCOUNTS['POS_GIFT_CERT'] )
        end

        def error_msg
            self.data.first.empty? ? 'Certificate Code not entered' : ''
        end

        def transaction
            self.data.first
        end

        def needs
            Array[ 'Certificate Code' ]
        end

    end # GiftCertificate

end
