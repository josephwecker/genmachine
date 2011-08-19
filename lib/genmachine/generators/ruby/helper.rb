module GenMachine
  module Helpers
    module Ruby
      INPUT = '__i'
      STATE = '__state'

      def rb_conditional(clause,states,clauses)
        has_eof_state = eof_state?(states) || eof_clause?(clauses)
        out = ''
        if clause[:cond].size > 0
          out += '('+clause[:cond].join(' || ')+')'
          out += "&& (#{rb_charset_cond(clause[:input],has_eof_state)})" unless clause[:input].nil?
        else
          out += rb_charset_cond(clause[:input],has_eof_state,',')
        end
        return rb_vars(out)
      end

      def rb_charset_cond(input,has_eof_state,sep='||')
        return 'true' if input.nil?
        outs = []
        sep = '||' if input[:kind] == :exclude
        input[:ranges].each do |range|
          if input[:kind] == :include
            if range.is_a? Array
              outs << "nl?" if (range[0] <= 0x0a) && (range[1] >= 0x0a)
              outs << "space?" if (range[0] <= 0x20) && (range[1] >= 0x20)
              outs << "(#{INPUT}>#{range[0]-1}&&#{INPUT}<#{range[1]+1})"
            else
              outs << case range
                      when 0x0a; 'nl?'
                      when 0x20; 'space?'
                      when :any; has_eof_state ? 'true' : '!eof?'
                      else "#{INPUT}==#{range}" end
            end
          end
        end
        out = outs.join(sep)
        out = '!('+out+')' if input[:kind] == :exclude
        return out
      end

      def rb_commands(clause,currstate)
        cmds = []
        cmds += rb_simple_acc_commands(clause[:acc])
        clause[:exprs].each do |expr|
          if expr.include? '<<'
            cmds += rb_acc_commands(expr)
          else
            cmds << rb_vars(expr.strip)
          end
        end
        cmds += rb_transition_commands(clause[:next],currstate)
        return cmds.join('; ')
      end

      def rb_transition_commands(st,currstate)
        st = st.strip.split(';').map(&:strip)
        out = []
        add_next = false
        st.each do |s|
          case
          when s =~ /^([^\(\[]+)(?:\[([^\]]*)\])?\(([^\)]*)\)$/   # Call another group
            funname = $1
            rename = $2
            params = $3.split(',').map{|p|rb_vars(p)}
            params << 's'
            params << "'#{rename}'" unless (rename.nil? or rename.strip=='')
            out << "#{STATE}=#{funname}(#{params.join(',')})"
            add_next = true
          when s =~ /^<done>$/
            out << "return(s)"
            add_next = false
          when s =~ /^<([^>]+)>$/
            out << "return(#{rb_vars($1)})"
            add_next = false
          when s =~ /^(:[a-zA-Z0-9_:-]+)$/
            out << "#{STATE}='#{$1}'" unless currstate == $1
            add_next = true
          else
            out << s
          end
        end
        out << 'next' if add_next
        return out
      end

      def rb_vars(str)
        str.tr('$','@').gsub /(:[a-zA-Z0-9_:-]+)/, '\'\1\''
      end

      def rb_simple_acc_commands(acc_phrase)
        case
        when (acc_phrase.nil? or acc_phrase == ''); return ['@fwd=true']
        when acc_phrase.strip == '<<'; return []
        when acc_phrase.strip =~ /^([a-zA-Z_][a-zA-Z0-9_]*)\s*<<\s*$/
          return ["#{rb_vars(acc_phrase.strip)}#{INPUT}"]
        else raise("Can't figure out your accumulator statement: #{acc_phrase}")
        end
      end

      def rb_acc_commands(acc_phrase)
        case
        when (acc_phrase.nil? or acc_phrase == ''); return ['@fwd=true']
        when acc_phrase.strip == '<<'; return []
        when acc_phrase.strip =~ /^([a-zA-Z_][a-zA-Z0-9_]*)\s*<<\s*(<?)([a-zA-Z_][a-zA-Z0-9_]*)$/
          into = $1
          value = $3
          clear_it = $2 == '<'
          into = rb_vars(into)
          value = rb_vars(value)
          if clear_it
            out = ["(#{into}<<#{value} if #{value}.size>0)"]
            out << "#{value}=UString.new"
          else
            out = ["#{into}<<#{value}"]
          end
          return out
        else raise("Can't figure out your accumulator statement: #{acc_phrase}")
        end
      end
    end
  end
end
