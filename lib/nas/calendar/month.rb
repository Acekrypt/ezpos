

require 'nas/calendar/week'
require 'date'

module NAS
module Calendar
class Month


    attr_reader :year, :number, :start

    def initialize( year, num )
        @year=year
        @number=num
        @start=DateTime.civil( 2006,11).to_time.beginning_of_week - 1.day
    end

    def day_names
        Date::DAYNAMES.dup
    end

    def name
        Date::MONTHNAMES[ @number ]
    end

    def each_week
        (0..5).each do | num |
            yield Week.new( self, num )
        end
    end

    def each_entry_for_day( day )

    end

end # Month
end # Calendar
end # NAS
