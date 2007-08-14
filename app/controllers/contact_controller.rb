
class ContactController < ApplicationController

    model :customer
    model :mail_contact
    model :mail_contact_group
    helper :pagination
    layout :select_layout

    def index
        redirect_to(:action =>"list")
    end

    def list
        @contact_pages = Paginator.new(self, MailContact.count("employee_id = #{self.user_id}"), CDF::CONFIG[:contacts_per_page], @params['page'])
        @contacts = MailContact.find(:all, :conditions=>["employee_id = #{self.user_id}"], :order=>['fname'], :limit=>CDF::CONFIG[:contacts_per_page], :offset=>@contact_pages.current.offset)

        if @params["mode"] == "groups"
            if @params["id"] and not @params["id"].nil? and not @params["id"] == ''
                @group_id = @params["id"].to_i
                @contacts_for_group = Hash.new
                for contact in @contacts
                    @contacts_for_group[contact.id] = 0 # initialize
                    for gr in contact.groups
                        if gr.contact_group_id.to_i == @group_id
                            @contacts_for_group[contact.id] = 1 # checked
                        end
                    end
                end
            end
        end
    end

    def listLetter
        letters = CDF::CONFIG[:contact_letters]
        @contact_pages = Paginator.new( \
                                       self, \
                                       MailContact.count \
                                       (["employee_id = %s and substr(UPPER(fname),1,1) = '%s'", \
                                         self.user_id, letters[@params['id'].to_i]]), \
                                       CDF::CONFIG[:contacts_per_page], @params['page'] \
                                       )
        @contacts = MailContact.find(:all, \
                                     :conditions=>["employee_id = %s and substr(UPPER(fname),1,1) = '%s'", \
                                                   self.user_id, letters[@params['id'].to_i]], \
                                     :order=>['fname'],  :limit=>CDF::CONFIG[:contacts_per_page], \
                                     :offset=>@contact_pages.current.offset \
                                     )

        if @params["mode"] == "groups"
            if @params["group_id"] and not @params["group_id"].nil? and not @params["group_id"] == ''
                @group_id = @params["group_id"].to_i
                @contacts_for_group = Hash.new
                for contact in @contacts
                    @contacts_for_group[contact.id] = 0 # initialize
                    for gr in contact.groups
                        if gr.contact_group_id.to_i == @group_id
                            @contacts_for_group[contact.id] = 1 # checked
                        end
                    end
                end
            end
        end

        render_action 'list'
    end

    def add
        @contact = MailContact.new
        @contact.employee_id = self.user_id

        # load related lists
        loadLists

        # Init groups: because of checkbox
        # Set all to 0 => unchecked
        @groups = Hash.new
        @contactgroups.each {|g|
            @groups[g.id] = 0
        }
    end

    def add_multiple
        @contact = MailContact.new
        @contact["file_type"] = "1"
    end

    def add_from_mail
        cstr = @params['cstr']
        retmsg = @params['retmsg']
        @session["return_to"] = url_for(:controller=>'webmail',
                                        :action=>'folders',
                                        :msg_id=>retmsg)
        # parse string
        if i = cstr.index("<")
            name, email = cstr.slice(0, i), cstr.slice((i+1)..(cstr.strip().index(">")-1))
            fname = name.split().first
            lname = name.split().last if name.split().size() > 1
        else
            fname, lname, email = "", "", cstr
        end

        if @contact = MailContact.find_by_user_email( self.user_id, email )
            # load related lists
            loadLists

            @contact.fname, @contact.lname = fname, lname

            # groups = @contact.groups
            @groups = Hash.new
            @contactgroups.each {|g|
                groupSelected = false
                @contact.groups.each {|gr|
                    if gr.contact_group_id.to_i == g.id.to_i
                        groupSelected = true
                        break
                    end
                }
                if groupSelected
                    @groups[g.id] = 1 # checked
                else
                    @groups[g.id] = 0 # unchecked
                end
            }
        else
            @contact = MailContact.new("fname"=>fname, "lname" => lname, "email" => email)

            @contact.employee_id = self.user_id

            # load related lists
            loadLists

            # Init groups: because of checkbox
            # Set all to 0 => unchecked
            @groups = Hash.new
            @contactgroups.each {|g|
                @groups[g.id] = 0
            }
        end
        render :action => "add"
    end

    def import_preview
        file = @params["contact"]["data"]

        flash["errors"] = Array.new

        if file.size == 0
            flash["errors"] << 'You haven\'t selected file or the file is empty'
            @contact = MailContact.new
            @contact["file_type"] = @params["contact"]["file_type"]
            render :action => "add_multiple"
        end

        file_type = @params["contact"]["file_type"]
        if file_type.nil? or file_type == '1'
            separator = ','
        else
            separator = /\t/

        end

        @contacts = Array.new
        emails = Array.new

        file.each {|line|
            cdata = line.strip.chomp.split(separator)
            cont = MailContact.new
            cont.fname = cdata[0].to_s.strip.chomp
            cont.lname = cdata[1].to_s.strip.chomp
            cont.email = cdata[2].to_s.strip.chomp

            # Check for duplicate emails in the file
            if emails.include?(cont.email)
                flash["errors"] << sprintf('Contact %', file.lineno.to_s) + ": " + 'The e-mail duplicates the e-mail of another record!'
            else
                emails << cont.email
            end

            @contacts << cont
        }

    end

    def import
        contacts_count = @params["contact"].length
        contacts_to_import = @params["contact"]
        @contacts = Array.new
        emails = Array.new

        flash["errors"] = Array.new

        for i in 0...contacts_count
            contact = MailContact.new
            contact.employee_id = self.user_id
            contact.fname = contacts_to_import[i.to_s]["fname"]
            contact.lname = contacts_to_import[i.to_s]["lname"]
            contact.email = contacts_to_import[i.to_s]["email"]

            begin
                # Check for duplicate emails in the submitted data
                if emails.include?(contact.email)
                    flash["errors"] << sprintf('Contact %', (i+1).to_s) + ": " + 'The e-mail duplicates the e-mail of another record!'
                else
                    emails << contact.email
                end
                # Check if contact is valid
                contact.valid?
            rescue CDF::ValidationError => e
                if not contact.errors.empty?
                    ["fname", "lname", "email"].each do |attr|
                        attr_errors = contact.errors.on(attr)
                        attr_errors = [attr_errors] unless attr_errors.nil? or attr_errors.is_a? Array

                        if not attr_errors.nil?
                            attr_errors.each do |msg|
                                flash["errors"] << l(:contact_addmultiple_errorforcontact, (i+1).to_s) + ": " + l(msg)
                            end
                        end
                    end
                end
            end # rescue

            @contacts << contact
        end # for

        # If there are validation errors - display them
        if not flash["errors"].nil? and not flash["errors"].empty?
            render :action => "import_preview"
        else
            # save
            begin
                for contact in @contacts
                    MailContact.create(contact.attributes)
                end
                # Set message for successful import
                flash["alert"] = Array.new
                flash["alert"] << l(:contact_addmultiple_success, @contacts.length.to_s)
                keep_flash()
                redirect_to(:action=>"list")
            rescue Exception => exc
                flash["errors"] << exc
                render :action => "import_preview"
            end
        end
    end


    def choose
        if @params["mode"] == "groups"
            save_groups
        end

        @tos, @ccs, @bccs = Array.new, Array.new, Array.new

        @params["contacts_to"].each{ |id,value| @tos << MailContact.find(id) if value == "1" } if @params["contacts_to"]
        @params["contacts_cc"].each{ |id,value| @ccs << MailContact.find(id) if value == "1" } if @params["contacts_cc"]
        @params["contacts_bcc"].each{ |id,value| @bccs << MailContact.find(id) if value == "1" } if @params["contacts_bcc"]

        @params["groups_to"].each{ |id,value|
            MailContactGroup.find(id).contacts.each {|c| @tos << c} if value == "1" } if @params["groups_to"]
        @params["groups_cc"].each{ |id,value|
            MailContactGroup.find(id).contacts.each {|c| @ccs << c} if value == "1" } if @params["groups_cc"]
        @params["groups_bcc"].each{ |id,value|
            MailContactGroup.find(id).contacts.each {|c| @bccs << c} if value == "1" } if @params["groups_bcc"]
    end

    def save_groups
        contacts_for_group = @params["contacts_for_group"]
        group_id = @params["group_id"]
        contact_group = MailContactGroup.find(group_id)


        contacts_for_group.each { |contact_id,value|
            contact = MailContact.find(contact_id)
            if value == "1" and not contact_group.contacts.include?(contact)
                contact_group.contacts << contact
            end
            if value == "0" and contact_group.contacts.include?(contact)
                contact_group.contacts.delete(contact)
            end
        }
        redirect_to(:action=>"list", :id=>group_id, :params=>{"mode"=>@params["mode"]})
    end

    def edit
        @contact = MailContact.find(@params["id"])
        # load related lists
        loadLists

        # groups = @contact.groups
        @groups = Hash.new
        @contactgroups.each {|g|
            groupSelected = false
            @contact.groups.each {|gr|
                if gr.contact_group_id.to_i == g.id.to_i
                    groupSelected = true
                    break
                end
            }
            if groupSelected
                @groups[g.id] = 1 # checked
            else
                @groups[g.id] = 0 # unchecked
            end
        }
        render :action => "add"
    end

    # Insert or update
    def save
        logger.info("BEGIN")
        if @params["contact"]["id"] == ""
            # New contact
            @contact = MailContact.create( @params["contact"] )
        else
            # Edit existing
            @contact = MailContact.find(@params["contact"]["id"])
            @contact.attributes = @params["contact"]
        end

        @contactgroups = MailContactGroup.find_by_employee(self.user_id)
        # Groups displayed
        groups = @params['groups']
        tempGroups = Array.new
        tempGroups.concat(@contact.groups)

        @contactgroups.each { |cgroup|
            includesCGroup = false
            tempGroups.each {|gr|
                if gr.contact_group_id.to_i == cgroup.id.to_i
                    includesCGroup = true
                    break
                end
            }
            if groups["#{cgroup.id}"] == "1" and not includesCGroup
                @contact.groups << cgroup
            end

            if groups["#{cgroup.id}"] == "0" and includesCGroup
                @contact.groups.delete(cgroup)
            end
        }
        if @contact.save
            if @params["paction"] == 'Save'
                redirect_to :controller => "/webmail/contacts", :action =>"list"
            else
                redirect_to :controller => "/webmail//contacts", :action =>"add"
            end
        else
            loadLists
            @groups = Hash.new
            @contactgroups.each {|g|
                if @contact.groups.include?(g)
                    @groups[g.id] = 1
                else
                    @groups[g.id] = 0
                end
            }
            render :action => "add"
        end
    end

    def delete
        MailContact.destroy(@params['id'])
        redirect_to(:action=>'list')
    end

    protected
    def secure_user?() true end
    def additional_scripts()
        add_s = ''
        if action_name == "choose"
            add_s<<'<script type="text/javascript" src="/javascripts/mail/global.js"></script>'
            add_s<<'<script type="text/javascript" src="/javascripts/mail/contact_choose.js"></script>'
        end
        add_s
    end

    def onload_function()
        if action_name == "choose"
            "javascript:respondToCaller();"
        else
            ""
        end
    end
    private

    def select_layout
        if @params["mode"] == "choose"
            @mode = "choose"
            @contactgroups = MailContactGroup.find_by_employee(self.user_id)
            'chooser'
        elsif @params["mode"] == "groups"
            @mode = "groups"
            'intranet'
        else
            @mode = "normal"
            'intranet'
        end
    end

    def loadLists
        if @contactgroups.nil?
            @contactgroups = MailContactGroup.find_by_employee(self.user_id )
        end
    end
end


