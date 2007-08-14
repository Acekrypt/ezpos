require 'nas/db'
require 'nas/util'
require 'socket'
module NAS

class Payment

class CreditCard

class Authorization

    def Authorization.avs_explain(avs)
	case avs[0..1]
	when 'YY'
	    'Name/Address matches, zip code matches'
	when 'YN'
	    'Name/Address matches, zip code does not match'
	when 'YX'
	    'Name/Address matches, zip code comparison not available'
	when 'NY'
	    'Name/Address does not match, zip code matches'
	when 'XY'
	    'Name/Address comparison not available, zip code matches'
	when 'NN'
	    'Name/Address comparison does not match, zip code does not match'
	when 'NX'
	    'Name/Address does not match, zip code comparison not available'
	when 'XN'
	    'Name/Address comparison not available, zip code does not match'
	when 'XX'
	    'Name/Address comparisons not available, zip code comparison not available'
	when ''
	    'No AVS Returned'
	else
	    'Unkown AVS Code'
	end
    end

    DB_TABLE = 'cc_authorizations'
    DB_SEQ = 'cc_authorizations_seq'
    DB_FIELDS = Array[ 'id','should_charge','transaction','sono','amount','name','avs','descrip','charged_from','charged_by','TIMEdate_recorded','used','status','processor_approved','forced','code','comments','card_id' ]

    include DB::Row

    attr_accessor :charge_amount
    
    def initialize( var )
	initialize_vars( var )
	@charge_amount=should_charge
    end

    def days_old
	((Time.now-self.date_recorded)/86400).round
    end

    def avs_approved?
	self.avs[0] == 89
    end

    def charging_transaction
	if charging_authorization
	    charging_authorization.transaction
	else
	    nil
	end
    end

    def card
	return @card if @card
	@card=NAS::Payment::CreditCard.new( @card_id )
    end

    def processor_message
	if self.processor_approved && ! self.avs_approved?
	    Authorization.avs_explain( self.avs )
	elsif ! self.processor_approved
	    self.descrip
	else
	    'Approved'
	end
    end

    def user_message
	if self.processor_approved && ! self.avs_approved?
	    'Your Bank told us that ' + Authorization.avs_explain( self.avs )
	elsif ! self.processor_approved
	    'Your bank denied payment with that card'
	else
	    'Approved'
	end
    end

    def Authorization.CreateFromWeb( results, order,card, user )

	error=false

	proc_appr=avs_appr='f'

	if results.has_key?( 'error' ) && ! results['error'].empty?
	    desc=results['error']
	elsif results.has_key? 'avs'
	    if results['approved']=='APPROVED'
		proc_appr='t'
		if results['avs'][0] == 89
		    avs_appr='t'
		end
	    else
		desc='Bank Denied (' + results['approved'] + ')'
	    end
	end

	ccforced='f'
	if ( avs_appr == 'f' ) && ( user.open_billing? || user.reseller? || card.international )
	    ccforced='t'
	end

	trans=results['ordernum']
	if ! trans || trans.empty?
	    trans=order.db_pk.to_s + ':' + ( rand(100000+100) ).to_s
	end

	if ! results['status'] || results['status'].empty?
	    results['status'] = 'DATA NOT VERIFIED'
	end

	results['avs']='' if ! results.has_key? 'avs'

	return Authorization.new( Hash[ 
				     'should_charge' => order.total,
				     'sono' => "WEB#{order.db_pk}",
				     'amount' => order.authorize_amount( card ),
				     'name' => card.name,
				     'avs' => results['avs'],
				     'transaction' => trans,
				     'descrip'=>desc,
				     'card_id'=>card.db_pk,
				     'date_recorded'=>Time.now,
				     'charged_from' => Socket.gethostbyname( order.ip_addr ).first,
				     'charged_by' => 'WWW',
				     'used' => false,
				     'status'=>results['status'],
				     'processor_approved'=>proc_appr,
				     'forced'=>ccforced,
				 ] )
    end

    def batch
	res=DB.instance.exec( "select #{Batch.fields} from cc_batch where charging_authorization_id = #{self.db_pk.to_s} and status='#{Batch::APPROVED}'" )
	if res.num_tuples > 0
	    return Batch.new( Util.DB2Hash( res, res.result.first ) )
	end
	nil
    end

    def charging_authorization
	if ! @ch_tran
	    res=DB.instance.exec("select #{fields} from cc_authorizations where sono = #{DB.quote(@sono)} and amount >= #{DB.quote(@charge_amount)} and used='f' and processor_approved='t' order by amount asc limit 1")
	    res.each do| row |
		@ch_tran=Authorization.new( Util.DB2Hash( res, row ) )
	    end
	end
	@ch_tran
    end

    def approved?
	self.processor_approved	&& ( self.avs_approved? || self.forced )
    end

    def avs_explanation
	Authorization.avs_explain( @avs )
    end


    def Authorization.all_with_sono( sono )
	sql="select #{fields} from #{DB_TABLE} where sono = #{DB.quote( sono )}"
	res = DB.instance.exec(sql)
	res.each do| row |
	    yield Authorization.new( Util.DB2Hash( res, row ) )
	end
    end

    def Authorization.with_transaction( transaction )
	sql="select #{fields} from #{DB_TABLE} where transaction=#{DB.quote( transaction )}"
	res = DB.instance.exec(sql)
	res.each do| row |
	    yield Authorization.new( Util.DB2Hash( res, row ) )
	end
    end

end

end # module CreditCards

end # module Payment

end # module NAS
