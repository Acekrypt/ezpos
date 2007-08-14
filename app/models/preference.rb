require_association 'customer'

class Preference < ActiveRecord::Base

    belongs_to :user


end
