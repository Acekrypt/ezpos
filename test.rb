#!/usr/bin/ruby



str='jslfda0123456789012345jkl'

if /\d{16}/.match( str )
    puts 'M'
else
    puts 'NM'
end

#date = Time.new -  86400
#report = NAS::INV::SalesReport.new( date )


#f = File.new('report.pdf','w')
#f.write( report.pdf )
#f.close



