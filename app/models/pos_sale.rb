class PosSale < ActiveRecord::Base

    belongs_to :customer, :class_name=>'Customer'

    has_many :skus, :class_name=>'PosSaleSku'
    has_many :returns, :class_name=>'PosSaleSkuReturns', :through => :skus
    has_many :payments, :class_name=>'PosPayment'


    def void(reason)
        self.voided=true
        self.void_reason=reason
    end

    def customer
        c=nil
        self.payments.each do | p |
            if p.payment_type == PosPaymentType::BILLING
                c=p.customer
                break
            end
        end
        c=self.payments.first.customer unless self.payments.empty?
        c.nil? ? P21Customer.find_by_code( DEF::ACCOUNTS['POS_CASH'] ) : c
    end

    def set_default_customer
        self.customer=P21Customer.find_by_code( DEF::ACCOUNTS['POS_CASH'] )
    end

    def paid_by
        ret='CASH'
        self.payments.each do | p |
            if p.payment_type == PosPaymentType::BILLING
                return p.customer.code
            end
            ret=p.payment_type.name
        end
        return ret
    end

    def tax_rate=( rate )
        skus.each{ | s | s.tax_rate=rate }
    end

    def discounted?
        skus.each{ | s | return true if s.discounted? }
        return false
    end

    def discount_amount
        m=Money.new
        skus.each{ | s | m+=s.discount }
        m
    end


    def total
        m=Money.new
        skus.each{ | s | m+=s.total }
        m
    end

    def total_returned
        m=Money.new
        skus.each{ | s | m+= s.total_returned }
        m
    end

    def total_tax_returned
        m=Money.new
        skus.each{ | s | m+= s.total_tax_returned }
        m
    end

    def returns
        ret=Array.new
        skus.each do | s |
            s.returns.each { | r | ret.push( r ) }
        end
        ret
    end

    def subtotal
        m=Money.new
        skus.each{ | s | m+=s.subtotal }
        m
    end

    def tax
        m=Money.new
        skus.each{ | s | m+=s.tax }
        m
    end

    def change_given
        rec=Money.new
        payments.each{ | s | rec+=s.amount }
        return rec-total
    end

    def self.find_on_date( date )
        self.find( :all, :conditions => [ "voided is null and date_trunc( 'day',pos_sales.occured) = ?", date.strftime('%Y-%m-%d') ],  :include=>[:customer, :payments], :order => "pos_sales.occured asc" )
    end

    def self.find_between_dates( begining, ending )
        self.find( :all, :conditions => [ "voided is null and date_trunc( 'day',pos_sales.occured) >= ? and date_trunc('day',pos_sales.occured) <= ?", begining.strftime('%Y-%m-%d'),ending.strftime('%Y-%m-%d') ],  :include=>[:customer, :payments], :order => "pos_sales.occured asc" )
    end

    def self.voided_on_date( date )
        self.find( :all, :conditions => [ "voided = 't' and date_trunc( 'day',pos_sales.occured) = ?", date.strftime('%Y-%m-%d') ],  :include=>[:customer, :payments], :order => "pos_sales.occured asc" )
    end

end
