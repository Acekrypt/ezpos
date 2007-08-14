require 'getoptlong'

env='production'
ago=1
opts = GetoptLong.new( [ "--enviroment", "-e",   GetoptLong::OPTIONAL_ARGUMENT],
                       [ "--days-ago",   "-d",   GetoptLong::OPTIONAL_ARGUMENT])
opts.each do | opt, arg |
    case opt
    when "--enviroment" then env = arg
    when "--days-ago" then ago = arg.to_i
    end
end

if env == 'production'
    DEBUG=false
else
    DEBUG=true
end

RAILS_ENV=env

require File.dirname( __FILE__ ) + '/../../config/environment'
