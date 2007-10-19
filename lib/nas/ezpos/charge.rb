#!/usr/bin/ruby

require 'getoptlong'

env='production'
opts = GetoptLong.new(  [ "--enviroment", "-e", GetoptLong::OPTIONAL_ARGUMENT],
                        [ "--amt","-a", GetoptLong::REQUIRED_ARGUMENT ],
                        [ "--num","-n", GetoptLong::REQUIRED_ARGUMENT ],
                        [ "--mon","-m", GetoptLong::REQUIRED_ARGUMENT ],
                        [ "--yr", "-y", GetoptLong::REQUIRED_ARGUMENT ] )

amount=num=mon=yr=''
opts.each do | opt, arg |
    case opt
    when "--enviroment"
       env = arg
    when "--amt"
        amount = arg
    when "--num"
        num = arg
    when "--mon"
        mon = arg
    when "--yr"
        yr = arg
    end
end

if env == 'production'
    DEBUG=false
else
    DEBUG=true
end

RAILS_ENV=env

require File.dirname( __FILE__) + '/../../../config/environment'

require 'nas/payments/credit_card/yourpay'

auth=NAS::Payment::CreditCard::YourPay.f2f_authorize( amount, num, mon, yr )

if auth.ok?
        puts auth.ordernum
        exit! 0
else
        puts auth.error
        exit! 1
end
