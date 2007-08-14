
require 'nas/calendar/day'

module NAS
module Calendar
class Week

    attr_reader :page, :number, :start


    include Reloadable

    def initialize( page, num )
        @page=page
        @number=num
        @start=page.start_date + num.weeks
    end

    def each_day
        (0..6).each do | num |
            yield Day.new( self, num )
        end
    end

end # Week
end # Calendar
end # NAS

