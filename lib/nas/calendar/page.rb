

require 'nas/calendar/week'
require 'nas/calendar/roman_numberal'
require 'date'

module NAS
module Calendar
class  Page
    # Maps Roman numeral digits to their integer values
    DIGITS = {
        'I' => 1,
        'V' => 5,
        'X' => 10,
        'L' => 50,
        'C' => 100,
        'D' => 500,
        'M' => 1000
    }
    @@digits_lookup = DIGITS.inject({   4 => 'IV',
                                        9 => 'IX',
                                        40 => 'XL',
                                        90 => 'XC',
                                        400 => 'CD',
                                        900 => 'CM'}) do |memo, pair|
        memo.update({pair.last => pair.first})
    end

    include Reloadable

    attr_reader :year, :month_number, :start_date, :end_date

    def initialize( current_user, year, num )
        @year=year
        @user=current_user
        @month_number=num
        @start_date=DateTime.civil( year,num).to_time.beginning_of_week-1.day
        @end_date=@start_date+5.weeks
        @entries=Hash.new
        each_week { | w | w.each_day{ | d | @entries[d.yday]=Array.new } }

        @user.viewing_calendars.each do | u |
            u.calendar_entries.find( :all,
                            :conditions=>[ '( start_time > ? and start_time < ? ) or ( end_time > ? and end_time < ? )',
                                           @start_date, @end_date, @start_date, @end_date ],
                            :order => 'start_time'
                            ).each do | ce |

                @entries[ ce.start_time.yday ] << ce
            end
        end


    end



    def day_names
        Date::DAYNAMES.dup
    end

    def month_name
        Date::MONTHNAMES[ @month_number ]
    end

    def each_week
        (0..4).each do | num |
            yield Week.new( self, num )
        end
    end

    def each_entry_for_day( day )
        @entries[ day.yday ].each{ | en | yield en }
    end

    def as_roman
        result = ''
        remainder = @month_number
        @@digits_lookup.keys.sort.reverse.each do |digit_value|
            while remainder >= digit_value
                remainder -= digit_value
                result += @@digits_lookup[digit_value]
            end
            break if remainder <= 0
        end
        result << ' / '
        remainder = @year
        @@digits_lookup.keys.sort.reverse.each do |digit_value|
            while remainder >= digit_value
                remainder -= digit_value
                result += @@digits_lookup[digit_value]
            end
            break if remainder <= 0
        end
        result
    end



    def prev_month_number
        if @month_number == 1
            12
        else
            @month_number-1
        end
    end

    def next_month_number
        if @month_number == 12
            1
        else
            @month_number+1
        end
    end


    def prev_month_year
        if @month_number == 1
            @year-1
        else
            @year
        end
    end

    def next_month_year
        if @month_number == 12
            @year+1
        else
            @year
        end
    end

end # Page
end # Calendar
end # NAS
