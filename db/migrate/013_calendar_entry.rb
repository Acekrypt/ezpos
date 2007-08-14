class CalendarEntry < ActiveRecord::Migration
  def self.up
      create_table "calendar_entries", :force => true do |t|
          t.column "start_time", :datetime, :null=>false
          t.column "end_time",  :datetime, :null=>false
          t.column "title", :text, :null=>false
          t.column "private", :bool
          t.column "description", :text, :null=>false
      end

      create_table( "calendar_entries_employees", { :force => true, :id=>false } ) do |t|
          t.column "calendar_entry_id", :integer, :null=>false
          t.column "employee_id", :integer, :null=>false
      end
      execute "alter table calendar_entries_employees add constraint calendar_entries_users_fkey1 foreign key ( employee_id ) references customers(id) on delete cascade"
      execute "alter table calendar_entries_employees add constraint calendar_entries_users_fkey2 foreign key ( calendar_entry_id ) references calendar_entries(id) on delete cascade"

      create_table( "calendar_sharing", { :force => true, :id=>false } ) do |t|
          t.column "employee_id", :integer, :null=>false
          t.column "viewing_id", :integer, :null=>false
      end
      execute "alter table calendar_sharing add constraint calendar_sharing_fkey1 foreign key ( employee_id ) references customers(id) on delete cascade"
      execute "alter table calendar_sharing add constraint calendar_sharing_fkey2 foreign key ( viewing_id ) references customers(id) on delete cascade"
  end

  def self.down
      drop_table :calendar_entries_employees
      drop_table :calendar_entries
  end
end
