
class MailFilterExpression < ActiveRecord::Base
    belongs_to :filter, :class_name=>'MailFilter'
end
