class Webmail < ActiveRecord::Migration
  def self.up
      execute <<-_SQL
CREATE TABLE mail_filters (
  id bigserial NOT NULL,
  name text default NULL,
  destination_folder text default NULL,
  employee_id bigint NOT NULL,
  present_order int default 1,
  PRIMARY KEY (id),
  FOREIGN KEY (employee_id) REFERENCES customers(id) ON DELETE CASCADE
);
CREATE INDEX mail_filters_idx1 ON mail_filters(employee_id);

CREATE TABLE mail_filter_expressions (
  id bigserial NOT NULL,
  field_name text default '^Subject' NOT NULL,
  operator text default 'contains' NOT NULL,
  expr_value text default '' NOT NULL,
  case_sensitive bool default FALSE,
  mail_filter_id bigint NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (mail_filter_id) REFERENCES mail_filters(id) ON DELETE CASCADE
);
CREATE INDEX mail_filter_expressions_idx1 ON mail_filter_expressions(mail_filter_id);

CREATE TABLE preferences (
  id serial NOT NULL,
  mail_type text default 'text/plain',
  wm_rows int default '20',
  user_id bigint default NULL,
  check_external_mail bool default false,
  PRIMARY KEY  (id)
);
CREATE UNIQUE INDEX preferences_idx1 ON preferences(user_id);

CREATE TABLE mail_contacts (
  id bigserial NOT NULL,
  fname text default NULL,
  lname text default NULL,
  email text default NULL,
  hphone text default NULL,
  wphone text default NULL,
  mobile text default NULL,
  fax text default NULL,
  notes text,
  create_date timestamp default NULL,
  delete_date timestamp default NULL,
  employee_id bigint default NULL,
  PRIMARY KEY  (id),
  FOREIGN KEY (employee_id) REFERENCES customers(id) ON DELETE CASCADE
);
CREATE INDEX mail_contacts_idx1 ON mail_contacts(employee_id);
CREATE INDEX mail_contacts_idx2 ON mail_contacts(employee_id,email);
CREATE INDEX mail_contacts_idx3 ON mail_contacts(email);

CREATE TABLE mail_contact_groups (
  id bigserial NOT NULL,
  name text default NULL,
  employee_id bigint default NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (employee_id) REFERENCES customers(id) ON DELETE CASCADE
);
CREATE INDEX mail_contact_groups_idx1 ON mail_contact_groups(employee_id);

CREATE TABLE mail_contact_group_groupings (
  contact_id bigint NOT NULL,
  contact_group_id bigint NOT NULL,
  PRIMARY KEY  (contact_id, contact_group_id),
  FOREIGN KEY (contact_id) REFERENCES mail_contacts(id) ON DELETE CASCADE,
  FOREIGN KEY (contact_group_id) REFERENCES mail_contact_groups(id) ON DELETE CASCADE
);
CREATE INDEX mail_contact_group_groupings_idx1 ON mail_contact_group_groupings(contact_id);
CREATE INDEX mail_contact_group_groupings_idx2 ON mail_contact_group_groupings(contact_group_id);

create table user_sessions (
        id              BIGSERIAL NOT NULL,
        session_id      TEXT NULL,
        data            TEXT NULL,
        updated_at      TIMESTAMP default null,
        PRIMARY KEY (id)
);
CREATE INDEX user_session_idx1 ON user_sessions(session_id);

CREATE TABLE mail_messages (
  id                    BIGSERIAL NOT NULL,
  folder_name           text NOT NULL,
  username              text NOT NULL,
  msg_id                text,
  uid                   BIGINT NOT NULL,
  "from"                TEXT,
  "from_flat"           TEXT,
  "to"                  TEXT,
  "to_flat"             TEXT,
  "subject"             TEXT,
  "content_type"        TEXT,
  "date"                TIMESTAMP,
  "unread"              BOOL default false,
  "size"                BIGINT,
  PRIMARY KEY (id)
);

CREATE INDEX mail_messages_idx1 ON mail_messages(folder_name, username);
CREATE INDEX mail_messages_idx2 ON mail_messages(folder_name, username, uid);

_SQL

  end

  def self.down

      drop_table :mail_messages
      drop_table :user_sessions
      drop_table :mail_contact_group_groupings
      drop_table :mail_contact_groups
      drop_table :mail_contacts
      drop_table :preferences
      drop_table :mail_filter_expressions
      drop_table :mail_filters
  end
end




__END__



