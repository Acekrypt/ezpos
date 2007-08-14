class EmpGroups < ActiveRecord::Migration
  def self.up
      create_table "groups", :force => true do |t|
          t.column "name", :text, :null=>false
          t.column 'description', :text, :null=>true
      end

      create_table( "employees_groups", { :force => true, :id=>false } ) do |t|
          t.column "employee_id", :integer, :null=>false
          t.column "group_id", :integer, :null=>false
      end

      add_index( :employees_groups, [ :employee_id, :group_id ], :unique => true )

      execute "alter table employees_groups add constraint employees_groups_fkey1 foreign key ( employee_id ) references customers(id) on delete cascade"
      execute "alter table employees_groups add constraint employees_groups_fkey2 foreign key ( group_id ) references groups(id) on delete cascade"

  end

  def self.down
      drop_table :employees_groups
      remove_index :employees_groups, :employee_id
      drop_table :groups
  end
end
