
CREATE SEQUENCE daily_receipts_seq;
create table daily_receipts(
  id int default nextval('daily_receipts_seq') primary key,
  date_covered date not null,
  checks numeric not null,
  cash numeric not null,
  credit_cards numeric not null
);

create unique index daily_receipts_indx1 on daily_receipts( date_covered );
