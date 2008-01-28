module PosPayment

    class CreditCard < Base

        BAD_CC_SWIPE = ';E/'

        set_default_customer Customer.find_by_code( DEF::ACCOUNTS['POS_CREDIT_CARD'] )
        set_needs [ 'Credit Card #','Expiration Month (MM)','Expiration Year (YY)' ]

        validates_length_of :data,:minimum=>3, :message=>'Credit Card not entered'


        def before_destroy
            if self.post_processed
                errors.push("Cannot delete a credit card payment once it's been batched.")
                return false
            else
                cv=CcVoid.new( { :auth_number=>self.data,
                                   :voided_at=>Time.now,
                                   :sale_id=>self.sale.id
                            } )
                cv.save!
            end
        end

        def self.is_bad_swipe?(txt)
            (txt.size < 15)
        end

        def self.charge_pending
            CreditCard.find( :all, :conditions=>[ "post_processed = 'f'" ], :include=>:sale ).each do | payment |
                next if payment.sale.voided
                RAILS_DEFAULT_LOGGER.info "BATCHING #{sale.id} #{payment.data} #{payment.amount}"
                res=NAS::Payment::CreditCard::YourPay.charge_f2f_authorization( payment.data, payment.amount )
                yield [ payment, res ] if block_given?
                payment.post_processed = true
                payment.save
            end
        end

    end # YourPay

end
