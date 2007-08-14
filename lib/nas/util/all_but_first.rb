
module NAS

    module Util

	class AllButFirst
	    attr_accessor :string

	    def initialize( str )
		@string=str
		@count = 0
	    end

	    def printed?
		@count > 1
	    end

	    def inc
		@count+=1
	    end

	    def +( p )
		if @count != 0
		    ret = @string + p.to_s
		else
		    ret = p.to_s
		end
		@count+=1
		ret
	    end

	    def to_s
		@count+=1
		if @count != 1
		    return @string
		end
		''
	    end

	    def reset
		@count=0
	    end

	end # class AllButFirst

    end # module Util

end # module NAS
