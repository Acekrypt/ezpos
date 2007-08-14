class P21Customers < ActiveRecord::Migration

    def self.up
        create_table :p21_customers, :id => false do |t|
            t.column :customer_id, :int
            t.column :legacy_id, :text
            t.column :terms_desc, :text
            t.column :net_days, :int
            t.column :customer_name, :text
            t.column :credit_limit_used, :float
            t.column :credit_limit, :float
            t.column :delete_flag, :boolean
            t.column :credit_status, :text
            t.column :mail_address1, :text
            t.column :mail_address2, :text
            t.column :mail_city, :text
            t.column :mail_state, :text
            t.column :mail_postal_code, :text
            t.column :central_phone_number, :text
        end
        add_index :p21_customers, :customer_id

        rename_column :customers, :id, :customer_id

        remove_column :customers, :email

        remove_column :customers, :password
        remove_column :customers, :ticket
        remove_column :customers, :title
        remove_column :customers, :timeout
        remove_column :customers, :created_on
        remove_column :customers, :company
        remove_column :customers, :country
        remove_column :customers, :pricelevel
        remove_column :customers, :comments
        remove_column :customers, :tax_rate
        remove_column :customers, :salesman
        remove_column :customers, :tax_cert_expiration
        remove_column :customers, :web_only
        remove_column :customers, :due_days
        remove_column :customers, :type
        remove_column :customers, :skulevel
        remove_column :customers, :credit_limit
        remove_column :customers, :acct_balance

        execute "drop index customers_index1"
        execute "drop index customers_index3"

        rename_column :customers, :address1, :mail_address1
        rename_column :customers, :address2, :mail_address2
        rename_column :customers, :city, :mail_city
        rename_column :customers, :state, :mail_state
        rename_column :customers, :zip, :mail_postal_code
        rename_column :customers, :phone, :central_phone_number
        rename_column :customers, :name, :customer_name

        add_column :customers, :terms_desc, :text
        add_column :customers, :net_days, :integer
        add_column :customers, :credit_limit_used, :integer
        add_column :customers, :credit_limit, :integer
        add_column :customers, :delete_flag, :boolean
        add_column :customers, :credit_status, :text
    end

    def self.down
        drop_table :p21_customers

        add_column :customers, :email, :text

        rename_column :customers, :customer_id, :id

        execute "create index customers_index1 on customers(upper(code))"
        execute "create index customers_index3 on customers(code)"

        add_column :customers, :password, :text
        add_column :customers, :ticket, :text
        add_column :customers, :title, :text
        add_column :customers, :timeout, :text
        add_column :customers, :created_on, :text
        add_column :customers, :company, :text
        add_column :customers, :country, :text
        add_column :customers, :pricelevel, :text
        add_column :customers, :comments, :text
        add_column :customers, :tax_rate, :text
        add_column :customers, :salesman, :text
        add_column :customers, :tax_cert_expiration, :text
        add_column :customers, :web_only, :text
        add_column :customers, :due_days, :text
        add_column :customers, :type, :text
        add_column :customers, :skulevel, :integer
        add_column :customers, :acct_balance, :float

        rename_column :customers, :mail_address1, :address1
        rename_column :customers, :mail_address2, :address2
        rename_column :customers, :mail_city, :city
        rename_column :customers, :mail_state, :state
        rename_column :customers, :mail_postal_code, :zip
        rename_column :customers, :central_phone_number, :phone
        rename_column :customers, :customer_name, :name

        remove_column :customers, :terms_desc
        remove_column :customers, :net_days
        remove_column :customers, :credit_limit_used
        remove_column :customers, :credit_limit
        remove_column :customers, :delete_flag
        remove_column :customers, :credit_status

        add_column :customers, :credit_limit, :float

    end



end
__END__

 DELETE FROM customers where customer_id not in ( select customer_id from pos_sales );

    update customers set customer_id=p21_customers.customer_id,mail_address1=p21_customers.mail_address1,mail_address2=p21_customers.mail_address2,mail_city=p21_customers.mail_city,mail_state=p21_customers.mail_state,mail_postal_code=p21_customers.mail_postal_code,central_phone_number=p21_customers.central_phone_number,customer_name=p21_customers.customer_name,terms_desc=p21_customers.terms_desc,net_days=p21_customers.net_days,credit_limit_used=p21_customers.credit_limit_used*100,credit_limit=p21_customers.credit_limit*100,delete_flag=p21_customers.delete_flag FROM p21_customers  where customers.code = p21_customers.legacy_id;
