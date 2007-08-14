#!/usr/bin/ruby

require 'nas/payment/credit_card/batch'

batches = Array.new
NAS::Payment::CreditCard::Batch.incomplete{ | b | batches.push(  b ) }

batches.each{ | batch |
    batch.charge
}

sleep( 20 )

batches.each{ | batch | batch.complete=true }
