module PosPayment
#     < ActiveRecord::Base

#     belongs_to :sale, :class_name=>'PosSale', :foreign_key=>:pos_sale_id, :polymorphic => true

#     belongs_to :customer

#     belongs_to :payment_type, :class_name=>'PosPaymentType', :foreign_key=>:pos_payment_type_id


    def self.non_credit_card
        Array[ Cash, Check, Billing, GiftCard ]
    end

    def self.all
        Array[ Cash, Check, Billing, GiftCard, CreditCardTerminal ]
    end


end
