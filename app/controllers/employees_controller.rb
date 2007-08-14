class EmployeesController < ApplicationController

    before_filter :login_required
    layout 'intranet'

    Groups=Struct.new(:Groups,:ppl,:fc,:lc )

    def select
        @employees=Employee.find :all
        @groups=[ Groups.new, Groups.new, Groups.new ]

        @groups.each{ | g | g.ppl = Array.new }
        @groups[0].fc = 'A'
        @groups[0].lc = 'G'
        @groups[1].fc = 'H'
        @groups[1].lc = 'N'
        @groups[2].fc = 'O'
        @groups[2].lc = 'Z'
        @employees.each do | e |
            fc=e.code.upcase[0]
            @groups.reverse.each do | g |
                if fc >= g.fc[0]
                    g.ppl << e
                    break
                end
            end
        end
        render :action=>'index'
    end
end
