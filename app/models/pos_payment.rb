class PosPayment < ActiveRecord::Base

    belongs_to :sale, :class_name=>'PosSale'
    belongs_to :customer
    belongs_to :payment_type, :class_name=>'PosPaymentType' 

    composed_of :amount, :class_name=>'Money', :mapping => [ %w(amount cents) ]

    composed_of :change, :class_name=>'Money', :mapping => [ %w(change cents) ]

end
