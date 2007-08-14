require_dependency 'customer'

class User < Customer

    attr_accessor :plaintext_password

    has_one :preferences, :class_name=>'Preference', :dependent => :destroy

    after_create :create_prefs


    def password=(pass)
        salt = ''
        2.times do
            char = ''
            char = (rand 255).chr until /[a-zA-Z0-9\.]/ =~ char
            salt << char
        end
        write_attribute(:password, pass.crypt( salt) )
    end

    def User.auth( login, password )
        user=User.find_by_code( login )
        if user && ( ! user.password.nil? ) \
            && ( user.password.size > 2 ) \
            && ( user.password == user.password.crypt( user.password ) )

            if user.is_a? User
                user.plaintext_password=password
                return user
            else
                user=Employee.auth_from_ldap( login, password )
                user.plaintext_password=password
                return user
            end
        else # perhaps they are an employee acct
            user=Employee.auth_from_ldap( login, password )
            user.plaintext_password=password
            return user
        end
    end

    def create_prefs
        self.preferences = Preference.new if self.preferences.nil?
    end

end

require 'employee'
