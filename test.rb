#!/usr/bin/ruby -I/usr/local/lib/rubylib

require 'sales_report'




date = Time.new 
report = SalesReport.new( date )


f = File.new('report.pdf','w')
f.write( report.pdf )
f.close

