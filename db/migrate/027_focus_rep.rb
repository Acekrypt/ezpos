class FocusRep < ActiveRecord::Migration
  def self.up
      NAS::ConfSettings.add('FOCUS_REP',false)
  end

  def self.down
      NAS::ConfSettings.remove('FOCUS_REP')
  end
end
