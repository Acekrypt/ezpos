
#require 'live_tree'
class CategoryController < ActionController::Base


#    include LiveTree
#    helper LiveTreeHelper

#    live_tree :category_tree, :model => :category

    def index
#	@root=Category::ROOT

#updater=NAS::DBSync.new
#updater.perform { | success,msg |
#    STDERR.puts msg if ( verbose || ! success )
#}

	render :text=>'hello'
    end


end
