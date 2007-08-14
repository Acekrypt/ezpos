require 'nas/payments/credit_card/c_yourpay.so'

module NAS

class Payment

class CreditCard

class YourPay

    attr_reader :raw

    private
    def initialize( results )
        @raw=results
    end

    public

    def ok?
        @raw['approved'] == 'APPROVED'
    end

    def error
        @raw['error']
     end

    def ordernum
        @raw['ordernum']
    end

    def YourPay.f2f_authorize( amount, cardnum, month, year )
        YourPay.new( ::CYourPay.FaceToFaceAuthorization( amount, cardnum.to_s, month.to_s, year.to_s ) )
    end

    def YourPay.web_authorize( order, card )
        YourPay.new( ::CYourPay.AuthorizeFromInternet( amount, cardnum.to_s, month.to_s, year.to_s ) )
    end

    def YourPay.charge_f2f_authorization( trans, amt )
        YourPay.new( ::CYourPay.ChargeFace2FaceAuthorization( trans, amt ) )
    end

end # YourPay

end # CreditCard

end # Payment

end # NAS
