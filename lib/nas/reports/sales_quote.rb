require "rubygems" rescue LoadError nil



module NAS
module Reports

class SalesQuote < NAS::PDF

    ITEM_W,DESC_W,UM_W,P1_W,LIM_W = *Array[ 35,100,15,20,30 ]
    attr_reader :user, :category

    def initialize( quote )
        super( 'P' )
        @quote=quote

        self.SetAutoPageBreak( 0 )
        self.AliasNbPages
        self.SetFillColor( 204, 204, 204 )
        @shaded=0
        oldcat=@category=nil
        SetFont( 'Times','', 10 )
        @quote.skus.each do | ref |
            if self.GetY.nil? || self.GetY > 200
                @shaded=0
                self.AddPage
            end
            layout_sku( ref )
        end

        @quote.last_printed_on = Time.now
    end

    def output
        self.Output
    end

    def table_width
        ret=ITEM_W+DESC_W+UM_W+P1_W
        return ret
    end

   def display
        file=Tempfile.new('corp_list_report')
        self.Output( file )
        file.flush
        `xpdf #{file.path}`
        file.unlink
    end


    def save
        file=File.new("#{filename}","w")
        self.Output( file )
        file.flush
    end

    def filename
        @time.strftime( "./%b-%Y.pdf" )
    end

    def layout_sku( sku )
        Cell( ITEM_W,6, sku.code , 1, 0, 'L', @shaded )
        Cell( DESC_W,6, sku.descrip , 1, 0, 'L', @shaded )
        Cell( UM_W,  6, sku.uom , 1, 0, 'C', @shaded )
        Cell( P1_W,  6, sku.price( @user ).format , 1, 1, 'R', @shaded )
        @shaded = ( @shaded == 0  ? 1 : 0 )
    end

    def Header
        SetFont('Times','BI',12)
        SetXY( 10, 10 )
        Cell( self.table_width ,5,"Alliance Medical Quotation for #{@quote.recipient_name}", 0, 1,'R' )
        self.SetFillColor( 131, 135, 160 )
        self.SetTextColor( 255, 255, 255 )
        Cell( ITEM_W,6, 'Item'        , 1, 0, 'L', 1 )
        Cell( DESC_W,6, 'Description' , 1, 0, 'L', 1 )
        Cell( UM_W,  6, 'U/M'         , 1, 0, 'C', 1 )
        Cell( P1_W,  6, 'Price'       , 1, 1, 'R', 1 )

      end

    def Footer
        SetFont('Times','BI',12)
        SetXY( 10, 260 )
        Cell( 80,5,@quote.last_printed_on.strftime("Prepared: %B %e, %Y"), 0, 0,'L' )
        Cell( table_width-80,5,"Page #{self.PageNo} / {nb}", 0, 0,'R' )
    end


end # class pricelist


class SkuCollectionXlsReport

    def initialize( user,list )
        @user=user
        @list=list
        @output=StringIO.new
        @path='/tmp/corplist' + $$.to_s + '.xls'
        @report=Spreadsheet::Excel.new( @path )

#       @report.set_custom_color( 40,255,102, 0 )
        default = @report.add_format
        centered = @report.add_format( :text_h_align=>2 )
        right = @report.add_format( :text_h_align=>3 )
        heading = @report.add_format( :bold=>1, :underline=>1 )
        url = @report.add_format( :color=>"blue", :bold=>0,:underline=>1, :text_h_align=>2 )

        ws = @report.add_worksheet( @user.code )
        ws.format_column( 0, 5, centered )
        ws.format_column( 1, 15, default )
        ws.format_column( 2, 65, default )
        ws.format_column( 3, 10, centered )
        ws.format_column( 4, 15, right )
        ws.format_column( 5, 65, default )
        ws.write(0,0,['View','Item','Description','U/M','Price','Category']  )
        if @list.is_a? CorpList
            ws.format_column( 6, 30, default )
            ws.write(0,6, 'Limits' )
        end
        ws.format_row( 0, 18, heading )
        y=1
        @list.each do | ref |
            sku=ref.sku
            ws.write( y,1,[ sku.code,sku.descrip, sku.uom, sku.price(user).to_f,ref.category.name ] )
            if @list.is_a? CorpList
                ws.write( y,6, ref.extra.to_s )
            end
            y+=1
        end
        @report.close
        File.new( @path ).each_line{ | b | @output.write b }
        File.unlink( @path )
    end

    def output
        @output.string
    end

    def display
        f=Tempfile.new 'listing'
        f.write @output.string
        f.flush
        `gnumeric #{f.path}`
        f.unlink
    end

end

end # Reports
end # NAS
#SalesQuote.run { |res| res.write }
