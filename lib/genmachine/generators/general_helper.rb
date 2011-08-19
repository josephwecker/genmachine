class String
  def to_underscored
    self.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    gsub(/[^a-zA-Z\d_]/,'_').
    downcase
  end

  def to_utf8_char_array
    self.unpack("U*")
  end
end

module GenMachine
  module Helpers
    module General
      def accumulates?(states)
        states.each do |name,clauses|
          clauses.each do |c|
            c[:exprs].each do |e|
              return true if e =~ /\bs\s*>>/
            end
          end
        end
        return false
      end

      def accumulators(states)
        accs = {}
        states.each do |name,clauses|
          clauses.each do |c|
            exprs = c[:exprs].dup
            exprs << c[:acc].dup
            exprs.each do |e|
              if e =~ /^([a-zA-Z_][a-zA-Z0-9_]*)?\s*>>\s*([a-zA-Z_][a-zA-Z0-9_]*)?$/
                accs[$1]=true unless ($1.nil? or $1 == '' or $1 == 'p' or $1 == 's')
                accs[$3]=true unless ($3.nil? or $3 == '' or $3 == 'p' or $3 == 's')
              end
            end
          end
        end
        return accs.keys
      end

      def makes_calls?(states)
        # TODO: implement
        false
      end

      def eof_state?(states)
        states.each{|name,clauses| return true if name=='{eof}'}
        return false
      end

      def eof_clause?(clauses)
        clauses.each{|c| return true if c[:cond].include?('eof')}
        return false
      end
    end
  end
end
