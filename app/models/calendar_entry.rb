
class CalendarEntry < ActiveRecord::Base

    has_and_belongs_to_many :employees

    def short_time
        self.start_time.strftime('%I:%M').gsub(/^0/,'')
    end

    def self.on_day( day )
        b=day.at_midnight
        e=day.at_midnight+1.day
        self.find( :all, :conditions=>[ '( start_time > ? and start_time < ? ) or ( end_time > ? and end_time < ? )',
                                        b, e, b, e ],
                   :order => 'start_time' )
    end

    def duration
        mins=( ( self.end_time - self.start_time ) / 60 ).round
        if 0 == ( mins % 1440 )
            return [ (mins / 1440), 'days' ]
        elsif 0 == ( mins % 60 )
            return [ (mins / 60  ), 'hours' ]
        else
            return [ mins, 'min' ]
        end
    end
end
