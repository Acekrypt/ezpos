module CalendarHelper

    def display_calendar(options = {}, &block)
        raise(ArgumentError, "No year given")  unless options.has_key?(:year)
        raise(ArgumentError, "No month given") unless options.has_key?(:month)

        block                        ||= Proc.new {|d| nil}

        defaults = {
            :table_class => 'calendar',
            :month_name_class => 'monthName',
            :other_month_class => 'otherMonth',
            :day_name_class => 'dayName',
            :day_class => 'day',
            :abbrev => (0..2),
            :first_day_of_week => 0
        }
        options = defaults.merge options

        first = Date.civil(options[:year], options[:month], 1)
        last = Date.civil(options[:year], options[:month], -1)

        first_weekday = first_day_of_week(options[:first_day_of_week])
        last_weekday = last_day_of_week(options[:first_day_of_week])

        day_names = Date::DAYNAMES.dup
        first_weekday.times do
            day_names.push(day_names.shift)
        end

        cal = %(<table class="#{options[:table_class]}" border="0" cellspacing="0" cellpadding="0">)
        cal << %(<thead><tr class="#{options[:month_name_class]}"><th colspan="7">#{Date::MONTHNAMES[options[:month]]}</th></tr><tr class="#{options[:day_name_class]}">)
        day_names.each {|d| cal << "<th>#{d[options[:abbrev]]}</th>"}
        cal << "</tr></thead><tbody><tr>"
        beginning_of_week(first, first_weekday).upto(first - 1) do |d|
            cal << %(<td class="#{options[:other_month_class]})
            cal << " weekendDay" if weekend?(d)
            cal << %(">#{d.day}</td>\n)
        end unless first.wday == first_weekday
        first.upto(last) do |cur|
            cell_text, cell_attrs = block.call(cur)
#            cell_text  ||= cur.mday
            cell_attrs ||= {:class => options[:day_class]}
            cell_attrs[:class] += " weekendDay" if [0, 6].include?(cur.wday)
            cell_attrs = cell_attrs.map {|k, v| %(#{k}="#{v}") }.join(" ")
            cal << "<td #{cell_attrs}><div class=\"mdd\">#{cur.mday}</div>#{cell_text}</td>\n"
            cal << "</tr><tr>" if cur.wday == last_weekday
        end
        (last + 1).upto(beginning_of_week(last + 7, first_weekday) - 1)  do |d|
            cal << %(<td class="#{options[:other_month_class]})
            cal << " weekendDay" if weekend?(d)
            cal << %(">#{d.day}</td>\n)
        end unless last.wday == last_weekday
        cal << "</tr></tbody></table>"
    end

    private

    def first_day_of_week(day)
        day
    end

    def last_day_of_week(day)
        if day > 0
            day - 1
        else
            6
        end
    end

    def days_between(first, second)
        if first > second
            second + (7 - first)
        else
            second - first
        end
    end

    def beginning_of_week(date, start = 1)
        days_to_beg = days_between(start, date.wday)
        date - days_to_beg
    end

    def weekend?(date)
        [0, 6].include?(date.wday)
    end


end
