# The filters added to this controller will be run for all controllers in the application.
# Likewise will all the methods added be available for all controllers.
require 'ezcrypto'

class ApplicationController < ActionController::Base

#    before_filter :login_required
    before_filter :add_scripts

    model :customer
    model :employee

    protected
    def secure_user?() true end
    def secure_cust?() false end
    def secure_group() nil end
    def additional_scripts() "" end
    def onload_function() "" end

    def user_id # returns customer id
        @session['user']
    end

    def current_user
        return @user if @user
        @user=User.find( user_id )
        return nil if @user.nil?
        if CDF::CONFIG[:crypt_session_pass]
            @user.plaintext_password=EzCrypto::Key.decrypt_with_password( CDF::CONFIG[:encryption_password],
                                                      CDF::CONFIG[:encryption_salt],
                                                      @session["wmp"])
        else
            @user.plaintext_password=@session["wmp"]
        end
        return @user
    end

    def user_logged_in?
        ! @session['user'].nil?
    end

    private
    def add_scripts
        @additional_scripts = additional_scripts()
        @onload_function = onload_function()
    end

    def login_required
        if ( secure_user? or secure_cust? ) and ! user_logged_in?
                @session["return_to"] = @request.request_uri
                redirect_to :controller=>"login", :action => "index"
                return false
        else
            if ( secure_group && ! current_user.member_of?( secure_group ) )
                @session['member_of'] = secure_group
                redirect_to :controller=>'login', :action=> 'non_member'
                return false
            end
        end
    end



    public

    def include_tinymce(mode="textareas",elements="")
        tinymce=''
        tinymce << '
       <script language="javascript" type="text/javascript" src="/javascripts/tiny_mce/tiny_mce.js"></script>
       <script language="javascript" type="text/javascript">
       tinyMCE.init({
        mode : "'
        tinymce << mode << '",'
        if mode == "exact"
            tinymce << 'elements : "' << elements << '",'
        end
        tinymce << '
        theme : "advanced",
        cleanup : true,
        width: "100%",
        remove_linebreaks : false,
        entity_encoding : "named",
        relative_urls : false,
        gecko_spellcheck : true,

        theme_advanced_buttons1_add : "fontselect,fontsizeselect",
        theme_advanced_buttons2_add : "separator,preview,zoom,iespell,forecolor,backcolor",
        theme_advanced_buttons2_add_before: "cut,copy,paste,separator,search,replace,separator",

        theme_advanced_source_editor_width : "700",
        theme_advanced_source_editor_height : "500",
        theme_advanced_styles : "Header 1=header1",
        theme_advanced_toolbar_location : "top",
        theme_advanced_toolbar_align : "left",
        theme_advanced_path_location : "none",
        extended_valid_elements : ""
           +"a[accesskey|charset|class|coords|href|hreflang|id|lang|name"
              +"|onblur|onclick|ondblclick|onfocus|onkeydown|onkeypress|onkeyup"
              +"|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|rel|rev"
              +"|shape|style|tabindex|title|target|type],"
           +"dd[class|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup"
              +"|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title],"
           +"div[align|class|id|lang|onclick"
              +"|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove"
              +"|onmouseout|onmouseover|onmouseup|style|title],"
           +"dl[class|compact|id|lang|onclick|ondblclick|onkeydown"
              +"|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover"
              +"|onmouseup|style|title],"
           +"dt[class|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup"
              +"|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title],"
           +"img[align|alt|border|class|height"
              +"|hspace|id|ismap|lang|longdesc|name|onclick|ondblclick|onkeydown"
              +"|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover"
              +"|onmouseup|src|style|title|usemap|vspace|width],"
           +"script[charset|defer|language|src|type],"
           +"style[lang|media|title|type],"
           +"table[align|bgcolor|border|cellpadding|cellspacing|class"
              +"|frame|height|id|lang|onclick|ondblclick|onkeydown|onkeypress"
              +"|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|rules"
              +"|style|summary|title|width],"
           +"td[abbr|align|axis|bgcolor|char|charoff|class"
              +"|colspan|headers|height|id|lang|nowrap|onclick"
              +"|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove"
              +"|onmouseout|onmouseover|onmouseup|rowspan|scope"
              +"|style|title|valign|width],"
           +"hr[align|class|id|lang|noshade|onclick"
              +"|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove"
              +"|onmouseout|onmouseover|onmouseup|size|style|title|width],"
           +"font[class|color|face|id|lang|size|style|title],"
           +"span[align|class|class|id|lang|onclick|ondblclick|onkeydown"
              +"|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover"
              +"|onmouseup|style|title]",
        external_link_list_url : "/cms/urlchoose/choose_tinymce",
        external_attachments_list_url : "/attachments/attachments/choose_tinymce",
        flash_external_list_url : "example_data/example_flash_list.js"
      });
      </script>'
        tinymce
    end

    helper_method :include_tinymce

    def include_simple_tinymce(mode="textareas",elements="")
        tinymce = ''
        tinymce << '<script language="javascript" type="text/javascript" src="/tiny_mce/tiny_mce.js"></script>
       <script language="javascript" type="text/javascript">
      tinyMCE.init({
        mode : "'
        tinymce << mode << '",'
        if mode == "exact"
            tinymce << 'elements : "' << elements << '",
      '
        end
        tinymce << '
        theme : "default",
        width : "100%",
        auto_reset_designmode : true
      });
      </script>'
        tinymce
    end

    helper_method :include_simple_tinymce

end
