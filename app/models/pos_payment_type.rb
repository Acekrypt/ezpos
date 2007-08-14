
class PosPaymentType < ActiveRecord::Base

Dir.glob( File.dirname( __FILE__ ) + '/pos_payment_types/*.rb' ).each do | f |
    require f
end

end

class PosPaymentType
    serialize :needs, Array

    attr_accessor :data

    CC_TERMINAL = PosPaymentType.find_by_id( 1 )
    CASH        = PosPaymentType.find_by_id( 2 )
    CHECK       = PosPaymentType.find_by_id( 3 )
    BILLING     = PosPaymentType.find_by_id( 4 )
    GIFT_CERT   = PosPaymentType.find_by_id( 5 )
    CREDIT_CARD = PosPaymentType.find_by_id( 6 )


    def self.non_credit_card
        Array[ CASH, CHECK, BILLING, GIFT_CERT ]
    end

    def self.all
        non_credit_card << CREDIT_CARD
    end

    def ok?
        self.error_msg.empty?
    end

    def should_open_drawer?
        false
    end

end

