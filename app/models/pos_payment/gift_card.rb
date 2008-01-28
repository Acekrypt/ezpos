module PosPayment

    class GiftCard < Base

        set_default_customer  Customer.find_by_code( DEF::ACCOUNTS['POS_GIFT_CERT'] )
        set_needs 'Certificate Code'

        validates_length_of :data,:minimum=>3, :message=>'Certificate Code not entered'

    end # GiftCard

end
