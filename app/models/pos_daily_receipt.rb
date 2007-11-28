class PosDailyReceipt < ActiveRecord::Base


    def self.find_between_dates( begining, ending )
        self.find( :all, :conditions => [ "day >= ? and day <=?", begining.strftime('%Y-%m-%d'), ending.strftime('%Y-%m-%d') ], :order => "day desc" )
    end


end
