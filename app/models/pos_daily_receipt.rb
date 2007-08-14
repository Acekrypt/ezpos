class PosDailyReceipt < ActiveRecord::Base

    composed_of :checks, :class_name=>'Money', :mapping => [ %w(checks cents) ]
    composed_of :cash, :class_name=>'Money', :mapping => [ %w(cash cents) ]
    composed_of :credit_cards, :class_name=>'Money', :mapping => [ %w(credit_cards cents) ]
    composed_of :billing, :class_name=>'Money', :mapping => [ %w(billing cents) ]
    composed_of :returns, :class_name=>'Money', :mapping => [ %w(returns cents) ]


    def self.find_between_dates( begining, ending )
        self.find( :all, :conditions => [ "day >= ? and day <=?", begining.strftime('%Y-%m-%d'), ending.strftime('%Y-%m-%d') ], :order => "day desc" )
    end


end
