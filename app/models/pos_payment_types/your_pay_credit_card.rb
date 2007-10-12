

class PosPaymentType

    class YourPayCreditCard < PosPaymentType


        def customer
            Customer.find_by_code( DEF::ACCOUNTS['POS_CREDIT_CARD'] )
        end

        def error_msg
            self.data.first.empty? ? 'Credit Card not entered' : ''
        end

        def transaction
            ''
        end

        def needs
            Array[ 'Credit Card #','Expiration Month (MM)','Expiration Year (YY)' ]
        end


        def YourPayCreditCard.charge_pending
            PosPayment.find( :all, :conditions=>[ "pos_payment_type_id=( select id from pos_payment_types where type = 'PosPaymentType::YourPayCreditCard') and transaction_id not like 'XXX-%%'", :include=>:sale ] ).each do | payment |
		next if sale.voided
                res=NAS::Payment::CreditCard::YourPay.charge_f2f_authorization( payment.transaction_id, payment.amount )
                yield [ payment, res ] if block_given?
                payment.transaction_id='XXX-'+payment.transaction_id
                payment.save
            end
        end

    end # YourPayCreditCard

end
