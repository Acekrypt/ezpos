
class MailFilter < ActiveRecord::Base
    has_many :expressions, :class_name=>'MailFilterExpression'

    belongs_to :employee
end
