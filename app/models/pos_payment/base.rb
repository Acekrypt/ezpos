
module PosPayment

    class Base < ActiveRecord::Base

	belongs_to :sale, :class_name=>'PosSale'

        def self.set_default_customer(c)
            @@def_customer=c
        end

	def name
		self.class.name.demodulize.titleize
	end

        def self.set_needs(n)
            if n.is_a? Array
                @needs = n
            else
                @needs = [n]
            end
        end

        set_table_name :pos_payments

        belongs_to :sale, :class_name=>'PosSale', :foreign_key=>:pos_sale_id

        belongs_to :customer

        validates_presence_of :customer, :message=>'Invalid Customer'
        validates_presence_of :sale

        def should_open_drawer?
            true
        end

        def default_customer
            nil
        end

        def before_validation_on_create
            if self.customer.nil?
                self.customer = @@def_customer
            end
        end

        def self.needs
            @needs || []
        end


    end

end
