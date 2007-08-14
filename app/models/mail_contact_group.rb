class MailContactGroup < ActiveRecord::Base

    has_and_belongs_to_many :groups, :class_name => "MailContactGroup", :join_table => "mail_contact_group_groupings", :association_foreign_key => "contact_group_id", :foreign_key => "contact_id"

    has_one :employee

    def self.find_by_employee( user_id )
        find_by_sql("select * from mail_contact_groups where employee_id = #{user_id} order by name asc")
    end
end
