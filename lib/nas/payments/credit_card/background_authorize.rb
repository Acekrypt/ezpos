require 'nas/dbtables/dbtables'
require 'nas/payment/credit_card'
require 'nas/payment/credit_card/yourpay'
require 'nas/payment/credit_card/authorization'

module NAS

class Payment

class CreditCard



class BackgroundAuthorization < DBTables::BackgroundAuthorizations


    def initialize( var )
	super( var )
    end

    def set_status
	( pid, authid, secs_running ) = 
	    DB.instance.single_row("select pid,authorization_id,extract( epoch from now()-started_on)::integer from background_authorizations where id = #{db_pk}")
	@secs_running = secs_running.to_i
	@dead = ( authid == 0 &&  @secs_running > 90 && ! File.exists?( "/proc/#{pid}" ) )
	@authid = authid == 0 ? nil : authid
    end

    def dead?
	set_status
	@dead 
    end

    def completed?
	set_status
	! @authid.nil?
    end

    def authorization
	set_status
	if @authid
	    NAS::Payment::CreditCard::Authorization.new( @authid )
	else
	    nil
	end
    end

    def BackgroundAuthorization.latest_on_order( order )
	row=DB.instance.singleval( "select #{BackgroundAuthorization.fields} from background_authorizations where web_order_id = #{order.db_pk} order by started_on desc limit 1" )
	if row
	    return BackgroundAuthorization.new( row )
	else
	    return nil
	end
    end

    def destory
	DB.instance.exec( "delete from background_authorizations where id = #{db_pk}" )
    end

    def BackgroundAuthorization.start( order,card,user )
	pid = fork
	if pid
	    sleep 0.4 # wait for child to record it's info
	    auth=BackgroundAuthorization.find_one_matching( Hash[ 'pid'=>pid ] )
	    Process.wait
	    return auth
	else # in child
	    Process.setsid                 # Become session leader.
 	    exit if fork                   # Zap session leader. See [1].
	    Dir.chdir "/"                  # Release old working directory.
	    File.umask 0000                # Ensure sensible umask. Adjust as needed.
	    STDIN.reopen "/dev/null"                         # Free file descriptors and
	    STDOUT.reopen "/tmp/cc-background-proc.log", "a" # point them somewhere sensible.
	    STDERR.reopen STDOUT           # STDOUT/ERR should better go to a logfile.
 	    DB.instance.reset_connection
	    me=BackgroundAuthorization.new(  Hash[
					       'pid'=>Process.pid,
					       'started_on'=>Time.now,
					       'web_order_id'=>order.db_pk,
					   ] )
	    results=YourPay.web_authorize( order, card ).raw
	    auth = NAS::Payment::CreditCard::Authorization.CreateFromWeb( results, order, card, user )
	    me.authorization_id = auth.db_pk
	    DB.instance.exec( "insert into web_order_authorizations( web_order_id, authorization_id ) values ( #{order.db_pk}, #{auth.db_pk} )" )
	end
    end
end

end

end

end
