module PosPayment

    class Billing < Base

        set_needs 'Customer Code'

        def name
            if self.data
                'Billing Account: ' + self.customer.code
            else
                'Billing Account'
            end
        end

        def customer
            if self.data
                Customer.magic_find( self.data )
            else
                nil
            end
        end

        def error_msg
            error=''
            c=self.customer
            if c.nil?
                error="Customer #{self.data.first} not found"
            elsif ! NAS::EZPOS::CustomerInfoDialog.new( c ).ok?
                error='Canceled'
            end
            error
        end

        def transaction
            self.data.first
        end


    end # BillingAccount

end
