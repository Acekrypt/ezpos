require 'gconf2'
require 'singleton'

module NAS

module EZPOS

class Settings
    BAD_CC_SWIPE = ';E/'

    @gConf = GConf::Client.default

    def Settings.[]( var )
        val=@gConf[ '/apps/ezpos/'+var ]
        return val.nil? ? '' : val
    end

    def Settings.[]=( name,val )
        return @gConf[ '/apps/ezpos/'+name ]=val
    end

end # Settings

end # EZPOS

end # NAS
