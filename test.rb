#!/usr/bin/ruby -I/usr/local/lib/rubylib

require 'inv/sales_report'

date = Time.new -  86400
report = NAS::INV::SalesReport.new( date )


f = File.new('report.pdf','w')
f.write( report.pdf )
f.close

