require_association 'customer'

class Preferences < ActiveRecord::Base

    belongs_to :user


end
