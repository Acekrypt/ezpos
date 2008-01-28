
class Customer < ActiveRecord::Base

    set_primary_key :customer_id


    def credit_hold?
        ( credit_limit_used > credit_limit || credit_status != 'GOOD' || net_days == 0 )
    end

    def credit_hold_explanation
        if credit_limit_used > credit_limit
            "has #{credit_limit_used} unpaid, with limit of #{credit_limit}"
        elsif credit_status != 'GOOD'
            "credit status is marked as #{credit_status}"
        elsif net_days == 0
            "account is not marked as open credit account"
        end
    end

    def code_n_name
        "#{customer_name} (#{self.id})"
    end

    def self.magic_find( code )
        if code =~ /\D/
            Customer.find( :first, :conditions => [ "code=?", code.upcase ] )
        else
            Customer.find( :first, :conditions => [ "customer_id=?", code ] )
        end
    end
end



