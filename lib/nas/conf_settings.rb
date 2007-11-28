module NAS

module ConfSettings

    def self.add(setting,value)
      File.open( "#{RAILS_ROOT}/config/settings.yml",'a' ) do | f |
            f.write( "#{setting}: #{value}\n" )
        end
    end

    def self.remove( setting )
        Tempfile.open('config') do | temp |
            File.open( "#{RAILS_ROOT}/config/settings.yml" ) do | f |
                f.each_line do | line |
                    temp.write line unless line=~/setting/
                end
            end
            temp.flush
            FileUtils.cp temp.path, "#{RAILS_ROOT}/config/settings.yml"
        end
    end

end

end
