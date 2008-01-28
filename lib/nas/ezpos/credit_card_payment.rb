require 'open4'

module NAS

module EZPOS

class CreditCardPayment < Gtk::Dialog


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
                @msg = "Error: #{e} was encounterd.\nMost likely this is becouse invalid information was submitted." if @msg.empty?
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
        ( num, mon,yr ) = @values
        match = /(\d+)=(\d{2})(\d{2})/.match( num )
        if match
            num=match[1]
            mon=match[3]
            yr =match[2]
        end
        cmd = "#{File.dirname( __FILE__ )}/charge.rb -e #{RAILS_ENV} --amt=#{@amount} --num=#{num} --mon=#{mon} --yr=#{yr}"
        RAILS_DEFAULT_LOGGER.info "Starting CC payment #{num}::#{mon}::#{yr}"
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
