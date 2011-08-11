module GenMachine
  class CharSet
    attr_accessor :kind
    def initialize(kind = :include)
      @kind = kind
      @include_intervals = []
      @include_any = false
    end

    def inspect() for_conditional.inspect end
    def [](k) for_conditional[k] end

    def for_conditional
      if @include_any
        return {:kind=>@kind, :ranges=>[:any]}
      else
        ivals = @include_intervals.map do |a,b|
          a == b ? a : [a,b]
        end
        return {:kind=>@kind, :ranges=>ivals}
      end
    end

    def +(val) self.send(:<<,val) end
    def <<(val)
      if val.is_a?(String) && val =~ /([^-])-([^-])/
          include_range($1,$2)
      elsif val.is_a?(Range)
        include_range(val.first, val.last)
      elsif val == :any
        @include_any = true
      else include_char(val) end
    end

    def include_char(char) include_range(char,char) end

    def include_range(from, to)
      from = from.utf8_chars[0] if from.is_a?(String)
      to = to.utf8_chars[0] if to.is_a?(String)
      @include_intervals << [from,to].sort
      if @include_intervals.length > 1
        @include_intervals.sort!
        merged = []
        curr_a, curr_b = @include_intervals.shift
        @include_intervals.each_with_index do |ab,i|
          a,b = ab
          if a <= (curr_b+1)
            curr_b = [curr_b,b].max
          else
            merged << [curr_a, curr_b]
            curr_a,curr_b = ab
          end
        end
        merged << [curr_a, curr_b]
        @include_intervals = merged
      end
    end
  end
end
