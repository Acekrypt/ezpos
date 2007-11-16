require 'tempfile'
require 'fileutils'

class Fullscreen < ActiveRecord::Migration

  def self.up
      if ['kc-register','jc-register'].include?( `hostname`.chomp )
          value = 'true'
      else
          value = 'false'
      end
      NAS::ConfSettings.add('FULL_SCREEN',value)
  end

  def self.down
      NAS::ConfSettings.remove('FULL_SCREEN')
  end

end
