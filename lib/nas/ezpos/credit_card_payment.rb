
module NAS

module EZPOS

class CreditCardPayment < Gtk::Dialog

    attr_reader :cc_number

    def initialize( values, amount )
        super()
        @msg=''
        @values=values
        @amount=amount
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
        ignored,status = Process::waitpid2(@io.pid,Process::WNOHANG)
        if status
            begin
                @ok = ( status.exitstatus == 0 )
                @msg = @io.readline.chomp
                RAILS_DEFAULT_LOGGER.info "CC EXIT PROCESS EXIT - #{@ok} - #{@msg}"
             rescue EOFError=>e
                @msg="Error: #{e} was encounterd.\nNo response was return from authorizor.Card MAY or MAY NOT be charged.\nContact support." if @msg.empty?
            ensure
                Gtk.timeout_remove( @timeout )
                self.destroy
                @io.close
            end
        else
            @pb.pulse
        end
    end


    def charge
        return if @io
        ( @cc_number, mon,yr ) = @values
        match = /(\d+)=(\d{2})(\d{2})/.match( @cc_number )
        if match
            @cc_number=match[1]
            yr =match[2]
            mon=match[3]
        end
        cmd = "#{File.dirname( __FILE__ )}/charge.rb -e #{RAILS_ENV} --amt=#{@amount} --num=#{@cc_number} --mon=#{mon} --yr=#{yr}"
        RAILS_DEFAULT_LOGGER.info "Starting CC payment #{@cc_number}::#{mon}::#{yr}"
        @io=IO.popen(cmd)
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
