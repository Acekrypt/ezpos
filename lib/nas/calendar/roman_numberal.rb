module NAS
module Calendar


    # Integers that look like roman numerals
class RomanNumeral
    attr_reader :to_s, :to_i

    @@all_roman_numerals = []

    # May be initialized with either a string or an integer
    def initialize(value)
        case value
        when Integer
            @to_s = value.to_s_roman
            @to_i = value
        else
            @to_s = value.to_s
            @to_i = value.to_s.to_i_roman
        end
        @@all_roman_numerals[to_i] = self
    end

    # Factory method: returns an equivalent existing object
    # if such exists, or a new one
    def self.get(value)
        if value.is_a?(Integer)
            to_i = value
        else
            to_i = value.to_s.to_i_roman
        end
        @@all_roman_numerals[to_i] || RomanNumeral.new(to_i)
    end

    def inspect
        to_s
    end

    # Delegates missing methods to Integer, converting arguments
    # to Integer, and converting results back to RomanNumeral
    def method_missing(sym, *args)
        unless to_i.respond_to?(sym)
            raise NoMethodError.new(
                                    "undefined method '#{sym}' for #{self}:#{self.class}")
        end
        result = to_i.send(sym,
                           *args.map {|arg| arg.is_a?(RomanNumeral) ? arg.to_i : arg })
        case result
        when Integer
            RomanNumeral.get(result)
        when Enumerable
            result.map do |element|
                element.is_a?(Integer) ? RomanNumeral.get(element) :
                    element
            end
        else
            result
        end
    end
end


end # Calendar

end # NAS
