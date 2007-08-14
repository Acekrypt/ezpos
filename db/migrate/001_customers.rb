class Customers < ActiveRecord::Migration
  def self.up
      sql = <<-_SQL

      CREATE FUNCTION beginning_of_last_month() RETURNS date STABLE AS
        'SELECT (( now() - ( extract( DAY from  now() )-1 ||'' day'')::interval )::date-''1 month''::interval)::date'
      LANGUAGE 'sql';

      CREATE FUNCTION end_of_last_month() RETURNS date STABLE AS
        'SELECT ( now() - ( extract( DAY from  now() ) ||'' day'')::interval )::date'
      LANGUAGE 'sql';

      CREATE TABLE customers
      (
       id serial primary key,
       email text null,
       code text not null,
       password text NULL,
       ticket text NULL,
       title text NULL,
       timeout int null,
       created_on timestamp not null default now(),
       company text NULL,
       name text NULL,
       address1 text not null,
       address2 text null,
       city text not null,
       state text not null,
       zip text not null,
       phone text null,
       country text null,
       pricelevel int not null default 1,
       skulevel int not null default 0,
       credit_limit numeric(10,2) not null default '0',
       acct_balance numeric(10,2) not null default '0',
       comments text null,
       tax_rate real not null,
       salesman text not null,
       tax_cert_expiration date not null,
       web_only boolean not null,
       due_days int null default 0,
       type text not null default 'Customer'
       );
      CREATE UNIQUE INDEX customers_index1 ON customers( upper(code) );
      CREATE UNIQUE INDEX customers_index3 ON customers( code );
      _SQL

      sql.split(';').each do |stmt|
          execute stmt
      end
  end

  def self.down
      execute "drop function beginning_of_last_month( )"
      execute "drop function end_of_last_month( )"
      drop_table  :customers
  end
end
