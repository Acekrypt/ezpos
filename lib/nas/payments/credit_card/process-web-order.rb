#!/usr/bin/ruby

require 'nas/payment'
require 'nas/user'
require 'nas/payment/credit_card/yourpay'
require 'nas/payment/credit_card/background_authorize'
require 'nas/inv/web_order'

order=NAS::INV::WebOrder.new( ARGV[0].to_i )

card=NAS::Payment::CreditCard.new( ARGV[1].to_i )

user=NAS::User.new( ARGV[2].to_i )

NAS::Payment::CreditCard::BackgroundAuthorization.start( order,card, user )


