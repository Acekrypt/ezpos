#!/usr/bin/ruby

require 'nas/db'
require 'nas/local_config'
require 'nas/payment/credit_card'
require 'nas/payment/credit_card/yourpay'
require 'nas/money/Money'

file=File.open( '/tmp/batch.log','w' )

res=NAS::DB.instance.exec( "SELECT transaction_id,amount,occured from payments where occured > (now() - '1 day'::interval)" )

res.each do | ( trans, amt, dte ) |

    res=YourPay.ChargeFace2FaceAuthorization( trans,amt )

    puts sprintf('%-30s%10.2f  %15s   %s',trans, amt.to_f, dte.split('.').first ,res['error'] )

    if res['approved'] != 'APPROVED'
	res.each{ |k,v| file.puts "#{k.to_s} => #{v.to_s}" }
    end

    
end
puts
puts
puts ' -------> PRESS ENTER TO EXIT <---------'
$stdin.gets

file.close
