#!/usr/bin/ruby -I/usr/local/lib/rubylib


require 'db'

#puts Time.local( '2004','10','21' )


#DB.instance

res = DB.instance.exec( 'select sales.id,sales.customer_id,sales.payment_id,sales.subtotal,sales.tax,extract(epoch from occured) from sales where date_trunc(\'day\',occured) = \'2004-04-28\'' )

i=0
for col in res.fields
    puts col + ' -> ' + res.type( i ).to_s
    i+=1
end



