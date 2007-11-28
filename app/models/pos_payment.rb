class PosPayment < ActiveRecord::Base

    belongs_to :sale, :class_name=>'PosSale', :foreign_key=>:pos_sale_id
    belongs_to :customer
    belongs_to :payment_type, :class_name=>'PosPaymentType', :foreign_key=>:pos_payment_type_id


end
