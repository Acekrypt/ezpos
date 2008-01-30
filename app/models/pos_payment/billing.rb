module PosPayment

    class Billing < Base

        set_needs 'Customer Code'


        def customer
            return self.data.empty? ? nil : Customer.magic_find( self.data )
        end


    end # BillingAccount

end
