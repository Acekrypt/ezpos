require 'nas/payments/credit_card/yourpay'
require 'open4'

module NAS

module EZPOS

class CreditCardPayment < Gtk::Dialog


    def initialize( payment )
        super()
        @payment=payment
        self.charge

        label = Gtk::Label.new( 'Processing Credit Card Payment' )

        vbox.pack_start( label, false )
        @pb=Gtk::ProgressBar.new

        @timeout=Gtk.timeout_add( 130 ) do
            self.pulse
        end

        self.decorated=false

        vbox.pack_start( @pb )

        show_all
        self.run
    end

    def pulse
        status = @io.wait(Process::WNOHANG)
        if status
            @ok = ( status.exitstatus == 0 )
            @msg = @io.stdout.readline
            Gtk.timeout_remove( @timeout )
            self.destroy
            @io.close
        else
            @pb.pulse
        end
    end


    def charge
	return if @io
        ( num, mon,yr ) = @payment.values
        match = /(\d+)=(\d{2})(\d{2})/.match( num )
        if match
            num=match[1]
            mon=match[3]
            yr =match[2]
        end
        STDERR.puts "#{num} #{mon} #{yr} "

        @io=Popen4.new("#{File.dirname( __FILE__ )}/charge.rb -e #{RAILS_ENV} --amt=#{@payment.amount} --num=#{num} --mon=#{mon} --yr=#{yr}")
    end

    def ok?
        @ok
    end

    def msg
        @msg
    end

end # CreditCardPayment


end # EZPOS

end # NAS
