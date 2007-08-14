require 'nas/calendar/page'

class CalendarController < ApplicationController

    layout 'intranet'
    before_filter :login_required

    def index
#        @entry = CalendarEntry.new
#        @entry.start_time = Time.at( params[:id].to_i ) + 8.hours
#        render :partial=>'entry'
        month=params[:month] ? params[:month] : Time.now.month
        year=params[:year] ? params[:year] : Time.now.year

        @page=NAS::Calendar::Page.new( current_user, year.to_i, month.to_i )
        set_viewing_calendars
    end

    def add_entry
        @entry = CalendarEntry.new
        @entry.start_time = Time.at( params[:at].to_i ) + 8.hours
        @entry.employees << current_user
        render :partial=>'entry'
    end

    def change_users
        users = [current_user]
        params[:user_ids].each do | uid,val |
            users << User.find( uid )
        end
        current_user.viewing_calendars=users
        set_viewing_calendars
        @page=NAS::Calendar::Page.new( current_user, 2006, 11 )
        render :partial=>'calpage'
    end

    def edit_entry
        @entry = CalendarEntry.find( params[:id] )
        render :partial=>'entry'
    end


    def del_entry
        @entry = CalendarEntry.find( params[:id] )
        day=@entry.start_time
        @entry.destroy
        render :partial=>'days_entries', :locals => { :entries => CalendarEntry.on_day( day ) }
    end

    def save_entry
        if params[:entry].key? 'id'
            @entry = CalendarEntry.find( params[:entry][:id] )
            @entry.update_attributes( params['entry'] )
         else
            @entry = CalendarEntry.new( params['entry'] )
         end

        case params['numtype']
        when 'min'
            @entry.end_time = @entry.start_time + params['num'].to_i.minutes
        when 'hours'
            @entry.end_time = @entry.start_time + params['num'].to_i.hours
        when 'days'
            @entry.end_time = @entry.start_time + params['num'].to_i.days
        end

        users=[]
        if params.key? 'user_ids'
            params[:user_ids].each do | uid,val |
                users << User.find( uid )
            end
        end
        @entry.employees = users
        @entry.save
        set_viewing_calendars
        render :partial=>'days_entries', :locals => { :entries => CalendarEntry.on_day( Time.at(params[:orig_day].to_i) ) }
    end

    def set_viewing_calendars
        @calendars = Hash.new
        num=0
        current_user.viewing_calendars.each do | user |
            @calendars[ user ] = "caln#{num}"
            num+=1
        end
    end

end
