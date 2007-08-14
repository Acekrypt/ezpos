require 'cdfmail'
require 'net/smtp'
require 'net/imap'
require 'mail2screen'
require 'ezcrypto'

class WebmailController < ApplicationController
#    uses_component_template_root

    # Administrative functions
    before_filter :login_required
    before_filter :obtain_cookies_for_search_and_nav, :only=>[:messages]
    before_filter :set_user
    before_filter :load_folders

    layout 'intranet', :except => [:view_source, :download]

    model :mail_filter, :mail_filter_expression,  :employee

    BOOL_ON = "on"

    def index
        redirect_to(:action=>"messages")
    end

    def error_connection
    end

    def refresh
        current_user.mailbox.reload
        redirect_to(:action=>'messages')
    end

    def manage_folders
        if operation_param == 'Add folder'
            current_user.mailbox.create_folder(CDF::CONFIG[:mail_inbox]+"."+params["folder_name"])
        elsif operation_param == '(Delete)'
            current_user.mailbox.delete_folder(params["folder_name"])
        elsif operation_param == '(Subscribe)'
        elsif operation_param == '(Select)'
        end
    end

    def messages
        @session["return_to"] = nil
        @search_field = params['search_field']
        @search_value = params['search_value']

        # handle sorting - tsort session field contains last reverse or no for field
        # and lsort - last sort field
        if @session['tsort'].nil? or @session['lsort'].nil?
            @session['lsort'] = "DATE"
            @session['tsort'] = {"DATE" => true, "FROM" => true, "SUBJECT" => true, "TO" => false}
        end

        case operation_param
        when 'copy'
            msg_ids = []
            messages_param.each { |msg_id, bool|
                msg_ids << msg_id.to_i if bool == BOOL_ON and dst_folder != @folder_name }  if messages_param
            folder.copy_multiple(msg_ids, dst_folder) if msg_ids.size > 0
        when 'move'
            msg_ids = []
            messages_param.each { |msg_id, bool|
                msg_ids << msg_id.to_i if bool == BOOL_ON and dst_folder != @folder_name } if messages_param
            folder.move_multiple(msg_ids, dst_folder) if msg_ids.size > 0
        when 'delete'
            msg_ids = []
            messages_param.each { |msg_id, bool| msg_ids << msg_id.to_i if bool == BOOL_ON } if messages_param
            folder.delete_multiple(msg_ids) if msg_ids.size > 0
        when 'mark read'
            messages_param.each { |msg_id, bool| msg = folder.mark_read(msg_id.to_i) if bool == BOOL_ON }  if messages_param
        when 'mark unread'
            messages_parach { |msg_id, bool| msg = folder.mark_unread(msg_id.to_i) if bool == BOOL_ON }  if messages_param
        when "SORT"
            @session['lsort'] = sort_query = params["scc"]
            @session['tsort'][sort_query] = (@session['tsort'][sort_query]? false : true)
            @search_field, @search_value = @session['search_field'], @session['search_value']
        when 'Search'
            @session['search_field'] = @search_field
            @session['search_value'] = @search_value
        when 'Show all'
            @session['search_field'] = @search_field = nil
            @session['search_value'] = @search_value = nil
        else
            @search_field = @session['search_field']
            @search_value = @session['search_value']
        end
        logger.info "Folder: #{@folder_name}"
        logger.info "Avail: #{current_user.email_folders}"
        folder=current_user.email_folders[ @folder_name ]
        sort_query = @session['lsort']
        reverse_sort = @session['tsort'][sort_query]
        query = ["ALL"]
        @page = params["page"]
        @page ||= @session['page']
        @session['page'] = @page
        if @search_field and @search_value and not(@search_field.strip() == "") and not(@search_value.strip() == "")
            @pages = Paginator.new self, 0, current_user.preferences.wm_rows, @page
            @messages = folder.messages_search([@search_field, @search_value], sort_query + (reverse_sort ? ' desc' : ' asc'))
        else
            @pages = Paginator.new self, folder.total, current_user.preferences.wm_rows, @page
            @messages = folder.messages(@pages.current.first_item - 1, current_user.preferences.wm_rows, sort_query + (reverse_sort ? ' desc' : ' asc'))
        end
    end

    def delete
        @msg_id = msg_id_param.to_i
        folder.messages().delete(@msg_id)
        redirect_to(:action=>"messages")
    end

    def reply # not ready at all
        @msg_id = msg_id_param.to_i
        @imapmail = folder.message(@msg_id)
        fb = @imapmail.full_body
        @tmail = TMail::Mail.parse(fb)

        @mail = prepare_mail
        @mail.reply(@tmail, fb, current_user.preferences.mail_type)

        render_action("compose")
    end

    def forward
        @msg_id = msg_id_param.to_i
        @imapmail = folder.message(@msg_id)
        fb = @imapmail.full_body
        @tmail = TMail::Mail.parse(fb)

        @mail = prepare_mail
        @mail.forward(@tmail, fb)

        render_action("compose")
    end

    def compose
        if @mail.nil?
            operation = operation_param
            if operation == 'Send'
                @mail = create_mail
                encmail = @mail.send_mail
                current_user.mailbox.message_sent(encmail)
                # delete temporary files (attachments)
                @mail.delete_attachments()
                return render("webmail/mailsent")
            elsif operation == 'Add'
                @mail = create_mail
                attachment = CDF::Attachment.new(@mail)
                attachment.file = params['attachment']
            else
                # default - new email create
                @mail = create_mail
            end
        end
    end

    def empty
        folder.messages(0, -1).each{ |message|
            folder.delete(message)
        }
        folder.expunge
        redirect_to(:action=>"messages")
    end

    def message
        @msg_id = msg_id_param
        @imapmail = folder.message(@msg_id)
        folder.mark_read(@imapmail.uid) if @imapmail.unread
        @mail = TMail::Mail.parse(@imapmail.full_body)
    end

    def download
        msg_id = msg_id_param
        imapmail = folder.message(msg_id)
        mail = TMail::Mail.parse(imapmail.full_body)
        if mail.multipart?
            get_parts(mail).each { |part|
                return send_part(part) if part.header and part.header['content-type']['name'] == params['ctype']
            }
            render("webmail/noattachment")
        else
            render("webmail/noattachment")
        end
    end

    def view_source
        @msg_id = msg_id_param.to_i
        @imapmail = folder.message(@msg_id)
        @msg_source = CGI.escapeHTML(@imapmail.full_body).gsub("\n", "<br/>")
    end

    def auto_complete_for_mail_to
        auto_complete_responder_for_contacts params[:mail][:to]
    end

    def auto_complete_for_mail_cc
        auto_complete_responder_for_contacts params[:mail][:cc]
    end

    def auto_complete_for_mail_bcc
        auto_complete_responder_for_contacts params[:mail][:bcc]
    end

    private

    def load_folders
        if ['messages', 'delete', 'reply', 'forward', 'empty', 'message', 'download',
            'filter', 'filter_add', 'view_source'].include?(action_name)

            if params["folder_name"]
                @folder_name = params["folder_name"]
            else
                @folder_name = session["folder_name"] ? @session["folder_name"] : CDF::CONFIG[:mail_inbox]
            end
            session["folder_name"] = @folder_name
            @folders = current_user.mailbox.folders if @folders.nil?
        end
    end

    def folder
        @folders[ @folder_name ]
    end

    def auto_complete_responder_for_contacts(value)
        # first split by "," and take last name
        searchName = value.split(',').last.strip

        # if there are 2 names search by them
        if searchName.split.size > 1
            fname, lname = searchName.split.first, searchName.split.last
            conditions = ['user_id = ? and LOWER(fname) LIKE ? and LOWER(lname) like ?', user_id, fname.downcase + '%', lname.downcase + '%']
        else
            conditions = ['user_id = ? and LOWER(fname) LIKE ?', user_id, searchName.downcase + '%']
        end
        @contacts = MailContact.find(:all, :conditions => conditions, :order => 'fname ASC',:limit => 8)
        if @contacts.empty?
            @contacts = Customer.find(:all, :conditions => ['LOWER(code) like ?', value],:order => 'LOWER(code) ASC',:limit => 8)
        end
        render :partial => 'contacts'
    end

    protected

    def additional_scripts()
    end

    private


    def create_mail
        m = CDF::Mail.new( current_user.temp_path )
        if params["mail"]
            ma = params["mail"]
            m.body, m.content_type, m.from, m.to, m.cc, m.bcc, m.subject =  ma["body"], 'multipart', ma["from"], ma["to"], ma["cc"], ma["bcc"], ma["subject"]
            if params["att_files"]
                att_files, att_tfiles, att_ctypes = params["att_files"], params["att_tfiles"], params["att_ctypes"]
                att_files.each {|i, value|
                    att = CDF::Attachment.new(m)
                    att.filename, att.temp_filename, att.content_type = value, att_tfiles[i], att_ctypes[i]
                }
            end
        else
            m.from, m.content_type = current_user.friendly_local_email, current_user.preferences.mail_type
        end
        m.customer_id = user_id
        m
    end

    def prepare_mail
        m = CDF::Mail.new(current_user.mail_temporary_path)
        m.from, m.content_type = current_user.friendly_local_email, current_user.preferences.mail_type
        m
    end


    def send_part(part)
        if part.content_type == "text/html"
            disposition = "inline"
        elsif part.content_type.include?("image/")
            disposition = "inline"
        else
            disposition = "attachment"
        end
        @headers['Content-Length'] = part.body.size
        @response.headers['Accept-Ranges'] = 'bytes'
        @headers['Content-type'] = part.content_type.strip
        @headers['Content-Disposition'] = disposition << %(; filename="#{part.header['content-type']['name']}")
        render_text part.body
    end

    def get_parts(mail)
        parts = Array.new
        parts << mail
        mail.parts.each { |part|
            if part.multipart?
                parts = parts.concat(get_parts(part))
            elsif part.content_type and part.content_type.include?("rfc822")
                parts = parts.concat(get_parts(TMail::Mail.parse(part.body))) << part
            else
                parts << part
            end
        }
        parts
    end

    def obtain_cookies_for_search_and_nav
        @srch_class = ((cookies['_wmlms'] and cookies['_wmlms'] == 'closed') ? 'closed' : 'open')
        @srch_img_src = ((cookies['_wmlms'] and cookies['_wmlms'] == 'closed') ? 'closed' : 'opened')
        @ops_class = ((cookies['_wmlmo'] and cookies['_wmlmo'] == 'closed') ? 'closed' : 'open')
        @ops_img_src = ((cookies['_wmlmo'] and cookies['_wmlmo'] == 'closed') ? 'closed' : 'opened')
    end


     def set_user
         @user=current_user
     end


    def msg_id_param
        params["msg_id"]
    end

    def messages_param
        params["messages"]
    end

    def dst_folder
        params["cpdest"]
    end

    def operation_param
        params["op"]
    end
end
