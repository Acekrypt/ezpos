require 'user'
require_dependency 'maildropserializator'
require 'ldap'

class Employee < User
    include MaildropSerializator

    has_and_belongs_to_many :calendar_entries
    has_and_belongs_to_many :groups
    has_and_belongs_to_many :viewing_calendars, :class_name=>'Employee', :join_table=>'calendar_sharing', :association_foreign_key=>'viewing_id', :include=>['calendar_entries'], :order=>'upper(code)'

    has_many :mail_contact_groups, :dependent => :destroy
    has_many :mail_contacts, :dependent => :destroy

    has_many :mail_filters, :dependent => :destroy, :order=>'present_order'

    def email_domain(email)
        email.gsub(/.*@/,'')
    end

    def email_folders
        return self.mailbox.folders
    end

    def temp_path
        '/tmp'
    end

    def mailbox
        return @mailbox if @mailbox
        begin
            @mailbox = IMAPMailbox.new
            @mailbox.connect( self.code, self.plaintext_password )
        rescue Exception => ex
            logger.error("Exception on imap login - #{ex} - #{ex.backtrace.join("\t\n")}")
        end
        @mailbox
    end

    def close_imap_session
        return if @mailbox.nil? or not(@mailbox.connected)
        @mailbox.disconnect
        @mailbox = nil
    end

    def member_of?( group_name )
        self.groups.include?( Group.find_by_name( group_name ) )
    end

    def Employee.auth_from_ldap( login, password )

        @mailbox = IMAPMailbox.new
        begin
            @mailbox.connect(login, password)
        rescue
            return nil
        end
        @mailbox.disconnect

        # ok, we know the pass is good,
        # now populate from the LDAP dir
        user = Employee.find_by_code login
        if user.nil?
            user=Employee.new
            user.code=login
            user.password=password
            user.populate_from_ldap
        end
        return user
    end

    def populate_from_ldap
        self.email = login + "@" + CDF::CONFIG[:send_from_domain]
        conn = LDAP::Conn.new( 'directory', 389 )
        conn.set_option(LDAP::LDAP_OPT_PROTOCOL_VERSION, 3)
        conn.search("ou=Users,dc=allmed,dc=net",
                    LDAP::LDAP_SCOPE_SUBTREE,"(&(uid=#{login})(objectclass=posixAccount))" ) do |e|
            h=e.to_hash
            self.created_on = Time.at( h[ 'sambaPwdLastSet' ].first.to_i )
            self.company = 'Alliance Medical'
            self.name = h.has_key?('displayName')  ? h['displayName'].first : self.code
            self.address1 = h.has_key?('street') ? h['street'].first : ''
            self.city = h.has_key?('postalAddress') ? h['postalAddress'].first : ''
            self.state = h.has_key?('postalAddress') ? h['postalAddress'].first.split('\W').last : ''
            self.zip = h.has_key?('postalCode') ? h['postalCode'].first : ''
            self.phone = h.has_key?('telephoneNumber') ? h['telephoneNumber'].first : ''
            self.pricelevel=6
            self.skulevel = 0
            self.credit_limit = Money::ZERO
            self.acct_balance = Money::ZERO
            self.tax_rate = 0
            self.salesman = ''
            self.tax_cert_expiration = Time.now
            self.web_only = true
            self.save
        end
        conn.search("ou=Groups,dc=allmed,dc=net",
                    LDAP::LDAP_SCOPE_SUBTREE,"(&(memberUid=#{login})(objectclass=posixGroup))" ) do |e|

            logger.error("Added Group: #{e['cn'].first} to user #{self.code}" )

            self.groups << Group.find( :first, :conditions =>['name=?', e['cn'].first ] )
        end
    end

end
