require 'nas/db/row'
require 'nas/payment/credit_card/authorization'
require 'nas/payment/credit_card/pending_charge'
require 'nas/payment/credit_card/charge/charge'
module NAS

class Payment

class CreditCard

class Batch

    DB_TABLE = 'cc_batch'
    DB_SEQ = 'cc_batch_seq'
    DB_FIELDS = Array[ 'id','status','authorization_id','amount','TIMEtime_queued','complete','charging_authorization_id' ]
    APPROVED = 'APPROVED'
    include DB::Row

    attr_accessor :authorization, :charging_authorization

    def initialize( var )
	initialize_vars( var )
	@authorization = Authorization.new( @authorization_id )
	@authorization.charge_amount=@amount
	if ( @charging_authorization_id )
	    @charging_authorization=Authorization.new( @charging_authorization_id )
	else
	    @charging_authorization=@authorization.charging_authorization
	end
    end

    def approved?
	self.status == APPROVED
    end

    def charging_transaction
	if @charging_authorization
	    @charging_authorization.transaction
	else
	    nil
	end
    end

    def charge
	return false if charged?
	if ! charging_transaction
	    self.status='NO TRANSACTION FOUND (amount to high?)'
	end
	begin
	    res = NAS::Payment::CreditCard::Charge.from_batch( self )
	    if ! res['error'].empty?
		self.status='Error: ' + res['error']
	    else
		self.status=res['approved']
		self.charging_authorization_id = @charging_authorization.db_pk
		@charging_authorization.used=true
	    end
	    true
	rescue Exception
	    msg = ''
	    for line in $!.backtrace
		msg += line
	    end
	    self.status='EXCEPTION: ' + $!.to_s + ' : ' + msg
	    false
	end
    end

    def charged?
	@charging_authorization_id
    end

    def Batch.add( auth,amount)
	Batch.new( Hash[ 'complete'=>'f', 'authorization_id' => auth.db_pk, 'status'=>'pending','amount'=>amount,'time_queued'=>Time.new] )
    end
    
    def Batch.with_amount( amount )
	sql=<<-EOS
	    select 
	#{fields} 
	from #{DB_TABLE} where #{DB_TABLE}.amount=#{DB.quote(amount)}
	EOS

	res = DB.instance.exec( sql )
	res.each do| row |
	    yield Batch.new( Util.DB2Hash( res, row ) )
	end
    end


    def Batch.with_sono( sono )
	sql=<<-EOS
	    select 
	#{fields} 
	from #{DB_TABLE}, #{Authorization::DB_TABLE} where #{DB_TABLE}.authorization_id = #{Authorization::DB_TABLE}.id and #{Authorization::DB_TABLE}.sono=#{DB.quote(sono)}
	EOS

	res = DB.instance.exec( sql )
	res.each do| row |
	    yield Batch.new( Util.DB2Hash( res, row ) )
	end
    end

    def Batch.between_dates( first, last )
	sql=<<-EOS
	    select 
	#{fields} 
	from #{DB_TABLE} 
	where
	    time_queued > to_date('#{first.strftime('%d%m%Y')}', 'DDMMYYYY') 
	and
	    time_queued < to_date('#{last.strftime('%d%m%Y')}', 'DDMMYYYY') + interval '1 day'
	and
	    complete='t'
	order by time_queued
	EOS
	res = DB.instance.exec( sql )
	res.each do| row |
	    yield Batch.new( Util.DB2Hash( res, row ) )
	end
    end

    def Batch.incomplete
	res = DB.instance.exec( 'select ' + fields + ' from ' + DB_TABLE + ' where complete=\'f\'')
	res.each do| row |
	    yield Batch.new( Util.DB2Hash( res, row ) )
	end
    end

    def Batch.seconds_running
	secs = DB.instance.singleval('SELECT ' + DB.epoch( '(now()-time_queued)', false ) + ' from cc_batch where complete=\'f\' order by time_queued limit 1');
	if secs
	    secs.to_i
	else
	    0
	end
    end

    def Batch.process_pending
	NAS::Payment::CreditCard::PendingCharge.all { |pc|
	    Batch.new( Hash[ 'complete'=>'f', 'authorization_id' => pc.authorization_id, 'status'=>'pending','amount'=>pc.amount,'time_queued'=>Time.new] )
	    pc.destroy
	}
	system( LocalConfig::NAS_LIB_ROOT + 'payment/credit_card/batch-runner.rb&' )
    end

    def Batch.in_progress?
	if DB.instance.singleval('select count(*) from cc_batch where complete=\'f\'') > 0
	    true
	else
	    false
	end
    end


end

end # module CreditCards

end # module Payment

end # module NAS
