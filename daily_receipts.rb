

class DailyReceipt
    DB_TABLE = 'daily_receipts'
    DB_SEQ = 'daily_receipts_seq'
    DB_FIELDS = Array['id','TIMEdate_covered', 'checks', 'cash', 'credit_cards']
    include DB::Row


    def initialize( var )
	@billing=0
	initialize_vars( var )
    end

    def total
	checks+cash+credit_cards
    end

    def formated_total
	sprintf('%.2f',total)
    end

    def formated_checks
	sprintf( '%0.2f',checks)
    end

    def formated_cash
	sprintf( '%0.2f',cash)
    end

    def formated_credit_cards
	sprintf( '%0.2f',credit_cards )
    end


    def DailyReceipt.find_on_date( date )
	rec = nil
	res = DB.instance.exec( 'select ' + fields + ' from daily_receipts where ' + DB.date_trunc('day','date_covered') + ' = \'' + date.strftime('%Y-%m-%d') + '\'' )
	res.each do | tuple |
	    rec = DailyReceipt.new( Util.DB2Hash( res, tuple ) )
	end
	rec
    end

end
