module PosPayment

    class CreditCard < Base

        BAD_CC_SWIPE = ';E/'

        set_default_customer Customer.find_by_code( DEF::ACCOUNTS['POS_CREDIT_CARD'] )
        set_needs [ 'Credit Card #','Expiration Month (MM)','Expiration Year (YY)' ]

        validates_length_of :data,:minimum=>3, :message=>'Credit Card not entered'



        def self.is_bad_swipe?(txt)
            (txt.size < 15)
        end

        def self.charge_pending
            PosPayment.find( :all, :conditions=>[ "pos_payment_type_id=( select id from pos_payment_types where type = 'PosPaymentType::YourPayCreditCard') and transaction_id not like 'XXX-%%'" ], :include=>:sale ).each do | payment |
                next if payment.sale.voided
                res=NAS::Payment::CreditCard::YourPay.charge_f2f_authorization( payment.transaction_id, payment.amount )
                yield [ payment, res ] if block_given?
                payment.transaction_id='XXX-'+payment.transaction_id
                payment.save
            end
        end

    end # YourPay

end
