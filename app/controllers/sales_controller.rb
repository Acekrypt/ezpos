class SalesController < ApplicationController

    layout 'intranet'

    in_place_edit_for :sales_quote_sku, :descrip
    in_place_edit_for :sales_quote_sku, :qty
    in_place_edit_for :sales_quote, :recipient_name

    before_filter :login_required , :except => :auto_complete_sku_code

    def secure_group
        'salesreps'
    end

    def new_quote
            redirect_to :action => "edit_quote"
    end

    def add_sku
        s=Sku.find( params[:id] )
        sku = SalesQuoteSku.from_sku s
        @sales_quote = SalesQuote.find( params[:q] )
        sku.sales_quote = @sales_quote
        sku.save

  #      render :partial=>'quote_items'

        render :update do |page|
            page.replace_html('quote_skus', :partial => 'quote_items' )
            page.replace_html('sortable_list_control',
                              sortable_element('skus_body', :handle=>'handle',:tag=>'tr', :complete =>'SkusList.reorder();', :url => { :action => :update_positions, :id=>@sales_quote.id } )
                              )

        end

    end

    def rm_sku
        SalesQuoteSku.destroy( params[:id] )
        render :nothing=>true
    end



    def edit_quote
        if params.key? :id
            @sales_quote = SalesQuote.find( params[:id] )
        else
            @sales_quote = SalesQuote.new
            @sales_quote.employee=self.current_user
            @sales_quote.save
            redirect_to :action => "edit_quote",:id=>@sales_quote.id
        end
    end

    def auto_complete_sku_code
        @items = Sku.find(:all,
                          :conditions => [ 'UPPER(code) LIKE ?',
                                           params[:code].upcase + '%' ],
                          :order => 'UPPER(code) ASC',
                          :limit => 8)
        render :partial => 'items'
    end

    def set_sales_quote_sku_price
        newp=Money.new( params[:value] )
        sku = SalesQuoteSku.find( params[:id] )
        if newp < sku.sku.cost
            render :text=>"Price may not be less than #{sku.sku.cost.format}", :status=>500
        else
            sku.price = newp
            sku.save
            render :text=>params[:value]
        end
    end


    def update_positions
        @sales_quote = SalesQuote.find( params[:id] )
        pos=0
        params[:skus_body].each do | id |
            logger.error "Id: #{id} / Pos: #{pos}"
            SalesQuoteSku.update( id, "present_order" => pos+=1 )
        end
        render :nothing=>true
    end



end
