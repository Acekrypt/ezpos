class PosPayments < ActiveRecord::Migration


    def self.insert_payment( id, name, od, gc, ve, gti,needs )
        execute <<-_SQL
        insert into pos_payment_types
        ( id,
          name,
          should_open_drawer,
          get_customer_func,
          validation_func,
          get_transaction_func,
          needs
          ) values
        (
         #{id},#{quote(name)},#{quote(od)},#{quote(gc)}, #{quote(ve)},#{quote(gti)},#{quote(needs)}
         )
        _SQL
    end

  def self.up

      execute <<-_SQL

      create table pos_payment_types
      (
       id serial primary key,
       name text NOT NULL,
       should_open_drawer boolean not null,
       get_customer_func text not null,
       validation_func text not null,
       get_transaction_func text not null,
       needs text not null
       );
      _SQL


      insert_payment( 1,
                      'Credit Card Terminal',
                      'f',
                      "Customer.find_by_code( DEF::ACCOUNTS['POS_CREDIT_CARD'] )",
                      "self.data.first.empty? ? 'Valid Credit Card Processing Transaction # not entered' : ''",
                      "self.data.first",
                      "---\n-   'Credit Card Processing Transaction #'" )

     insert_payment( 2,
                     'Cash',
                     't',
                     "Customer.find_by_code( DEF::ACCOUNTS['POS_CASH'] )",
                     "(self.data.first =~ /\d/) ? '' : 'Amount must be numeric'",
                     "''",
                     "--- []" )

      insert_payment( 3,
                      'Check',
                      'f',
                      "Customer.find_by_code( DEF::ACCOUNTS['POS_CHECK'] )",
                      "self.data.first.empty? ? 'Valid Telecheck or Check # not entered' : ''",
                      "self.data.first",
                      "---\n-   'Telecheck Transaction #'" )

      insert_payment( 4,
                      'Billing Account',
                      'f',
                      "Customer.find_by_code( self.data.first )",
                      "self.customer.nil? ? \"Customer \#{self.data.first} not found\" : ''",
                      "self.customer.code",
                      "---\n-    'Customer Code'" )

      insert_payment( 5,
                      'Gift Certificate',
                      'f',
                      "Customer.find_by_code( DEF::ACCOUNTS['POS_GIFT_CERT']  )",
                      "self.data.first.empty? ? 'Certificate Code not entered' : ''",
                      "self.data.first",
                      "---\n-    'Certificate Code'" )


      insert_payment( 6,
                      'Credit Card',
                      'f',
                      "Customer.find_by_code( DEF::ACCOUNTS['POS_CREDIT_CARD'] )",
                      "self.data.first.empty? ? 'Credit Card swipe not entered' : ''",
                      "''",
                      "---\n-    Credit Card #\n-    Expiration Month\n-    Expiration Year" )



      execute <<-_SQL
      create table pos_payments
      (
       id serial primary key,
       amount int not null,
       transaction_id text null,
       customer_id int null
         REFERENCES customers(id)
         MATCH FULL
         ON DELETE CASCADE
         ON UPDATE CASCADE,
       pos_sale_id int null
         REFERENCES pos_sales(id)
         MATCH FULL
         ON DELETE CASCADE
         ON UPDATE CASCADE,
       pos_payment_type_id int NOT NULL
         REFERENCES pos_payment_types(id)
         MATCH FULL
         ON DELETE CASCADE
         ON UPDATE CASCADE
       );
      _SQL
  end

  def self.down
      drop_table :pos_payments
      drop_table :pos_payment_types
  end
end
