require 'nas/util/all_but_first'

module NAS

module Util

    class Comma < ::NAS::Util::AllButFirst

        def initialize
            super(',')
        end
    end

    def Util.englishify(collection)
	size=collection.size-1
	cur=0
	ret=''
	collection.each do | el |
	    if cur==0
		ret+=el.to_s
	    elsif cur==size
		if cur == 1
		    ret += ' and ' + el.to_s
		else
		    ret += ', and ' + el.to_s
		end
	    else
		ret += ', ' + el.to_s
	    end
	    cur+=1
	end	
	ret
    end


    
end

end # module NAS
