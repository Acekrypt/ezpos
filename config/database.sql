CREATE TABLE categories (
   id serial primary key,
   parent_id int NULL default 0
	REFERENCES categories(id)
	MATCH FULL
	ON DELETE CASCADE
	ON UPDATE CASCADE,
   name text NOT NULL,
   short_descrip text NULL,
   long_descrip text NULL,
   position int default 1
);
CREATE INDEX categories_indx1 ON categories(parent_id);


