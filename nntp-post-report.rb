#!/usr/bin/ruby -I/usr/local/lib/rubylib

require 'net/smtp'
require 'base64'
require 'inv/sales_report'
require 'nntp'

s = Net::NNTP.new('news.allmed.net')

host = `hostname --long`

msgid = String.new('<')
for i in 0..35
    msgid << rand(26)+97
end

boundary ='------------060206040805030707000202'
msgid += '@' + host.chomp + '>'

date = Time.new - 86400 
report = INV::SalesReport.new( date )
report_name = 'JC_Store_' + date.strftime("%m-%d-%Y") + '.pdf'


msg=<<EOS
From: #{LocalConfig::LOCATION_NAME} <#{LocalConfig::LOCATION_EMAIL}>
Newsgroups: allmed.stores.reports
Organization: Alliance Medical
Subject: #{date.strftime("%Y-%m-%d")} #{LocalConfig::LOCATION_NAME} #{ report.total_sales }
User-Agent: Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.4) Gecko/20030624
X-Accept-Language: en-us, en
MIME-Version: 1.0
Content-Type: multipart/mixed;
 boundary="#{boundary}"


This is a multi-part message in MIME format.

--#{boundary}
Content-Type: text/html; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit\r\n

#{report.html}

--#{boundary}
Content-Type: application/pdf;
 name="#{report_name}"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="#{report_name}"

EOS

encode64( report.pdf ).each_line{ | line |
    msg+=line.chomp
    msg+="\r\n"
}
msg += '--' + boundary + '---'

f = File.new( '/tmp/report.pdf',"w" )

f.write( report.pdf )

f.close

#puts s.post( msg )

