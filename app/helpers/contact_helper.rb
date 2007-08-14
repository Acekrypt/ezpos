module ContactHelper
    def link_import_preview() "/intra/contacts/import_preview" end
    def link_main_index() "/intra/folders" end
    def link_contact_save() "/intra/contacts/save" end
    def link_contact_import() "/intra/contacts/import" end
    def link_contact_choose() "/intra/contacts/choose" end




    def link_contact_group_list
        link_to('Groups', :controller => "/intra/contacts/contact_group", :action => "list")
    end

    def link_folders
        link_to('Folders', :controller=>"intra", :action=>"messages")
    end

    def link_send_mail
        link_to('Compose', :controller=>"intra", :action=>"compose")
    end

    def link_mail_prefs
        link_to( 'Preferences', :controller=>"intra", :action=>"prefs")
    end

    def link_mail_filters
        link_to( 'Filters', :controller=>"intra", :action=>"filters")
    end

end
