module NAS

module EZPOS

class AboutDialog < Gtk::AboutDialog


    def initialize
        super()
        self.logo = Gdk::Pixbuf.new( RAILS_ROOT + '/public/images/alliance-logo.png' )
        self.name = "EZPOS"
        self.authors = ["Nathan Stitt <stittn@allmed.net>"]
        self.comments = <<-EOS
This is a Point of Sale program written to
interface with Alliance Medical's product catalog

Address: #{ip_address}
EOS
        self.copyright = "Copyright (C) 2006 Alliance Medical"
        self.version = self.revision
        self.website = 'http://www.allmed.net/'
    end

     def ip_address
        addr=`ifconfig ppp0 | grep 'inet addr:'`
        addr=`ifconfig eth0 | grep 'inet addr:'` if addr.empty?
        addr=~/addr\:(\d+)\.(\d+)\.(\d+)\.(\d+)\s+/
    "#{$1}.#{$2}.#{$3}.#{$4}"
    end

     def revision
         `svn  info #{File.dirname(__FILE__)}/$(ls -t #{File.dirname(__FILE__)}|head -n1)|grep Revision`
     end
end # AboutDialog

end # EZPOS

end # NAS

