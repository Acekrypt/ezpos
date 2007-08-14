require 'ezcrypto'

class LoginController < ApplicationController

#    model :customer

    def index
        if user_logged_in?
            redirect_to :controller =>"webmail", :action=>"index"
        end
    end

    def authenticate
        if user = User.auth( params['login_user']["email"], params['login_user']["password"])
            session["user"] = user.id
            if CDF::CONFIG[:crypt_session_pass]
                @session["wmp"] = EzCrypto::Key.encrypt_with_password(CDF::CONFIG[:encryption_password],
                                                                      CDF::CONFIG[:encryption_salt],
                                                                      @params['login_user']["password"])
            else
                # dont use crypt
                @session["wmp"] = @params['login_user']["password"]
            end

            if session["return_to"]
                redirect_to_path(session["return_to"])
                session["return_to"] = nil
            else
                redirect_to :action=>"index"
            end
        else
            login_user = User.new
            flash["error"] = 'Wrong email or password specified.'
            redirect_to :action => "index"
        end
    end

    def logout
        reset_session
        flash["status"] = 'User successfully logged out'
        redirect_to :action => "index"
    end

    protected

    def need_subdomain?() true end
    def secure_user?() false end

    private

end
