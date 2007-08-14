class EmployeePrefsController < ApplicationController

    before_filter :login_required
    layout 'intranet'

    def index
        @user = current_user
        @mailpref = current_user.preferences
    end

    def save
        @mailpref=current_user.preferences
        if params['op'] == 'Save'
            if params['user']
                current_user.name = params['user']['name']
                current_user.save
            end
            @mailpref.attributes = params["mailpref"]
            @mailpref.save
            @session["wmimapseskey"] = nil
        end
        @mailpref.save
        redirect_to :action=>:index
    end

    def update_filter_positions
        params[:filters].each_with_index do |id, position|
            MailFilter.update( id, :present_order => position)
        end

        render :nothing => true
    end

    def filter
        if params['op']
            @filter = MailFilter.new( params['filter'])
            @filter.id = params['filter']['id'] if params['filter']['id'] and ! params['filter']['id'].empty?
            @filter.employee_id = user_id
            params['expression'].each do |index, expr|
                unless expr["expr_value"].nil? or expr["expr_value"].strip == ""
                    @filter.expressions << MailFilterExpression.new(expr)
                end
            end
            case params['op']
            when 'Add'
                @filter.expressions << MailFilterExpression.new
            when 'Save'
                if params['filter']['id'] and ! params['filter']['id'].empty?
                    @sf = MailFilter.find(params['filter']['id'])
                    @sf.name, @sf.destination_folder = @filter.name, @filter.destination_folder
                    @sf.expressions.each{|expr| MailFilterExpression.delete(expr.id) }
                    @filter.expressions.each {|expr|
                        mf=MailFilterExpression.new(expr.attributes)
                        mf.filter=@sf
                        @sf.expressions << mf
                    }
                else
                    @sf = MailFilter.create(@filter.attributes)
                    @sf.present_order = current_user.mail_filters.size
                    @filter.expressions.each {|expr|
                        mf=MailFilterExpression.new( expr.attributes )
                        mf.filter = @sf
                        @sf.expressions << mf
                    }
                end
                # may be some validation will be needed
                @sf.save
                current_user.serialize_filters
                return redirect_to( :action=>:index )
            end
            @expressions = @filter.expressions
        else
            @filter = MailFilter.find(params["id"]) if params["id"]
            @expressions = @filter.expressions
        end
        @destfolders=current_user.email_folders
    end

    def filter_delete
        MailFilter.delete(params["id"])
        # reindex other filters
        current_user.serialize_filters
        redirect_to :action=>'index'
    end

    def filter_up
        filt = current_user.mail_filters.find(params['id'])
        ufilt = current_user.mail_filters.find_all("order_num = #{filt.order_num - 1}").first
        ufilt.order_num = ufilt.order_num + 1
        filt.order_num = filt.order_num - 1
        ufilt.save
        filt.save
        current_user.serialize_to_file
        redirect_to :action=>"filters"
    end

    def filter_down
        filt = MailFilter.find(params["id"])
        dfilt = current_user.mail_filters[filt.order_num]
        dfilt.order_num = dfilt.order_num - 1
        filt.order_num = filt.order_num + 1
        dfilt.save
        filt.save
        current_user.serialize_to_file
        redirect_to :action=>"filters"
    end

    def filter_add
        @filter = MailFilter.new
        @filter.expressions << MailFilterExpression.new
        @expressions = @filter.expressions
        @destfolders = current_user.email_folders
        render_action("filter")
    end

end
