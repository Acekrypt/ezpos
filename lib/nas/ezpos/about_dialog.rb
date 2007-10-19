module NAS

module EZPOS

class AboutDialog < Gtk::AboutDialog


    def initialize
        super()
        self.logo = Gdk::Pixbuf.new( RAILS_ROOT + '/public/images/alliance-logo.png' )
        self.name = "EZPOS"
        self.authors = ["Nathan Stitt <stittn@allmed.net>"]
        self.version = `svnversion #{RAILS_ROOT}`
        self.copyright = "Copyright (C) 2007 Alliance Medical"
        self.website = 'http://www.allmed.net/'
        self.comments = <<-EOS
This is a Point of Sale program written to
interface with Alliance Medical's product catalog

Address: #{ip_address}
Embeded software versions: #{Gtk::BINDING_VERSION.join('.')} / #{Gtk::VERSION.join('.')}
#{`svn info #{RAILS_ROOT} | grep 'Last Changed Date'`}
EOS
    end

     def ip_address
        addr=`ifconfig ppp0 | grep 'inet addr:'`
        addr=`ifconfig eth0 | grep 'inet addr:'` if addr.empty?
        addr=~/addr\:(\d+)\.(\d+)\.(\d+)\.(\d+)\s+/
    "#{$1}.#{$2}.#{$3}.#{$4}"
    end

end # AboutDialog

end # EZPOS

end # NAS

