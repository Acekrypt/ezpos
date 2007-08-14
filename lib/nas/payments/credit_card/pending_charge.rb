require 'nas/db'
require 'nas/util'
require 'nas/payment/credit_card/authorization'
require 'nas/payment/credit_card/charge/charge'

module NAS

class Payment

class CreditCard

class PendingCharge

    DB_TABLE = 'cc_pending_charges'
    DB_SEQ = 'cc_pending_charges_seq'
    DB_FIELDS = Array[ 'id','authorization_id','amount' ]

    include DB::Row

    attr_accessor :authorization
    
    def initialize( var )
	initialize_vars( var )
	@authorization = Authorization.new( @authorization_id )
	@authorization.charge_amount=@amount
    end

    def PendingCharge.all
	res = DB.instance.exec( 'select ' + fields + ' from ' + DB_TABLE + ' order by id desc') 
	res.each do| row |
	    yield PendingCharge.new( Util.DB2Hash( res, row ) )
	end
    end

    def destroy
	super
    end
end

end # module CreditCards

end # module Payment

end # module NAS
