class Skus < ActiveRecord::Migration

  def self.up

      sql=<<-_SQL

      CREATE TABLE skus
      (
       id serial primary key,
       webonly boolean NULL,
       code text NOT NULL,
       descrip text NOT NULL,
       um text NOT NULL,
       price1 int NOT NULL,
       level1 text NULL,
       price2 int NOT NULL,
       level2 text NULL,
       price3 int NOT NULL,
       level3 text NULL,
       price4 int NOT NULL,
       level4 text NULL,
       price5 int NOT NULL,
       level5 text NULL,
       price6 int NOT NULL,
       level6 text NULL,
       on_hand int not null,
       isbn text null,
       cost numeric null,
       category text null
       );

      CREATE INDEX skus_index1 ON skus (code text_pattern_ops);

      insert into skus ( id, webonly,code,descrip,um,price1,level1,price2,level2,price3,level3,price4,level4,price5,level5,price6,level6,on_hand ) values ( #{DEF::NONEXISTANT_SKU_ID}, 't','NOT EXISTENT','Sorry, we no longer sell this item.','none',0.0,0,0,0,0,0,0,0,0,0,0,0,0 );

      insert into skus ( id, webonly,code,descrip,um,price1,level1,price2,level2,price3,level3,price4,level4,price5,level5,price6,level6,on_hand  ) values (#{DEF::RETURNED_SKU_ID},'t','RETURN','Returned Item.','none',0,0,0,0,0,0,0,0,0,0,0,0,0 );

      CREATE OR REPLACE FUNCTION newly_recd_sku(text) RETURNS boolean AS '
      DECLARE
        abc text;
      BEGIN
        select into abc item from newly_recd_skus where item like trim( trailing ''ABC'' from $1 ) || ''%'';
        IF FOUND THEN
          RETURN TRUE;
        ELSE
          RETURN FALSE;
        END IF;
      END;
      ' LANGUAGE 'plpgsql' stable;

      select setval( 'skus_id_seq', #{DEF::SKU_FIRST_ID} );

      create function sbt_date( text ) returns date IMMUTABLE  AS 'select to_date( $1, ''MM/DD/YY'' )' language 'SQL';

      create function web_onhand( text ) returns integer AS 'select on_hand from skus where code = substr( $1,4)' language 'SQL';
      create function web_isbn( text ) returns integer AS 'select on_hand from skus where code = substr( $1,4)' language 'SQL';
      _SQL
      execute sql
  end

  def self.down
      drop_table  :skus
      execute "drop function newly_recd_sku(text)"
      execute "drop function sbt_date( text )"
      execute "drop function web_onhand( text )"
      execute "drop function web_isbn( text )"
  end

end
