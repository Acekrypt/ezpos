
require 'nas/calendar/week'
require 'nas/calendar/page'

module NAS
module Calendar
class Day


    attr_reader :date, :number

    def initialize( week, num )
        @week=week
        @number=num
        @date=week.start + num.days
    end

    def num
        @date.day
    end

    def member_of_month?
        ( ( ( @date.year == @week.page.year ) && ( @date.month == @week.page.month_number ) ) )
    end

    def each_entry
        @week.page.each_entry_for_day( self ){ | e | yield e }
    end

    def entries
        ret=[]
        each_entry{ | e | ret << e }
        ret
    end

    def to_i
        @date.to_i
    end

    def yday
        @date.yday
    end

end # Day
end # Calendar
end # NAS

