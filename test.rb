#!/usr/bin/ruby -I/usr/local/lib/rubylib

require 'net/smtp'
require 'base64'
require 'sales_report'
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
report = SalesReport.new( date )
report_name = 'JC_Store_' + date.strftime("%m-%d-%Y") + '.pdf'



msg=<<EOS
From:                       #{LocalConfig::LOCATION_NAME} <#{LocalConfig::LOCATION_EMAIL}>
Newsgroups:                 test
Organization:               Alliance Medical
Path:                       unknown!not-for-mail
Subject:                    #{report.title}
MIME-Version:               1.0
Content-Type:               multipart/mixed;
 boundary="#{boundary}"

This is a multi-part message in MIME format.

#{boundary}
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

for great justice

#{boundary}
Content-Type: application/pdf;
 name="#{report_name}"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="#{report_name}"

EOS


msg +=  encode64( report.pdf )
msg += boundary + '---'


puts msg
puts s.post( msg )



__END__


smtp = Net::SMTP.new('mail.allmed.net')
smtp.start
smtp.ready('bob@allmed.net', 'nathan@allmed.net') do |a|
    a.write "From: \"North Dallas Warehouse\" <ndwe@airmail.net>\r\n"
    a.write 'Subject: ' + report.title + "\r\n"
    a.write "MIME-Version: 1.0\r\n"
    a.write "Message-ID: #{msgid}\r\n"
    a.write "Content-Type: multipart/mixed;\r\n\tboundary=\"----=_NextPart_000_0007_01C40826.6EDC3040\"\r\n\r\n"
    a.write "\r\nThis is a multi-part message in MIME format.\r\n\r\n"
    a.write "------=_NextPart_000_0007_01C40826.6EDC3040\r\n"
    a.write "Content-Type: text/plain;\r\n"
    a.write "\tcharset=\"iso-8859-1\"\r\n"
    a.write "Content-Transfer-Encoding: quoted-printable\r\n"
    a.write "\r\n"
    a.write "your document is silly!\r\n"
    a.write "\r\n"
    a.write "------=_NextPart_000_0007_01C40826.6EDC3040\r\n"
    a.write "Content-Type: application/pdf;\r\n"
    a.write "\tname=\"final.pdf\"\r\n"
    a.write "Content-Transfer-Encoding: base64\r\n"
    a.write "Content-Disposition: attachment;\r\n"
    a.write "\tfilename=\"final.pdf\"\r\n"
    a.write "\r\n"
    a.write encode64( report.pdf )

    a.write "------=_NextPart_000_0007_01C40826.6EDC3040--"
end

