module GenMachine
  # This is a quick and dirty parser used for bootstrapping. Which means
  # it'll eventually be replaced when the real parser is written as a
  # genmachine table.
  class SpecParser
    def initialize(files,opts)
      @table = []
      @files = files
      @opts = opts
    end

    def build
      c_name = c_type = c_args = c_cmds = c_first_state = c_states = nil
      new_fun = false
      @files.each do |fname|
        File.new(fname,'r').each_with_index do |line, line_no|
          line = line.strip
          det = line[0..0]
          if det == '|' or det == ':'
            re = (det=='|' ? '\|' : det) + '(?: |$)'
            cols = line.split(/#{re}/,-1)[1..-1].map(&:strip)
            if det=='|' && cols[0].include?('(')
              new_fun = true
              unless c_name.nil?
                @table << [c_name, c_type, c_args, c_cmds, c_first_state, process_states(c_states)]
              end
              parts = cols[0].split('(')
              c_name = parts.shift.to_underscored
              c_args, c_type = parts.join('(').split(/::(U|\[\]|\{\})$/)
              c_args = c_args[0..-2].split(',')
              c_type ||= '[]'
              c_states = []
              c_cmds = (cols[3]||'').split(';')
              c_first_state = cols[4]
              # TODO: error if cols[1] or cols[2] have anything
            elsif det == ':' && new_fun
              c_args += cols[0].sub(/\)$/,'').split(',')
              c_cmds += (cols[3]||'').split(';')
              c_first_state += (cols[4]||'')
            elsif det == '|'
              new_fun = false
              conditionals, inputs = parse_input(cols[1])
              c_states << {:name  => cols[0],
                           :input => inputs,
                           :cond  => conditionals,
                           :acc   => cols[2],
                           :exprs => (cols[3]||'').split(';').map(&:strip),
                           :next  => cols[4]}
            elsif det == ':' && (c_states.size > 0)
              conditionals, inputs = parse_input(cols[1],c_states[-1][:input])
              c_states[-1][:name] += (cols[0]||'')
              c_states[-1][:input] = inputs
              c_states[-1][:cond] += conditionals
              c_states[-1][:acc]  += cols[2]
              c_states[-1][:exprs]+= (cols[3]||'').split(';').map(&:strip)
              c_states[-1][:next] += cols[4]
            end
          end
        end
        unless c_name.nil?
          @table << [c_name, c_type, c_args, c_cmds, c_first_state, process_states(c_states)]
        end
      end
      if @opts[:debug]
        require 'pp'
        pp @table
      end
      return @table
    end

    # consolidate same-name states and (eventually) combine / optimize where
    # appropriate.
    def process_states(instates)
      outstates = {}
      instates.each do |inst|
        name = inst.delete(:name)
        outstates[name] ||= []
        outstates[name] << inst
      end
      return outstates
    end

    def parse_input(val,inputs=nil)
      iters = 0
      conds = []
      val.gsub! /([^\\])\\\[/, '\1<left-square-bracket>'
      val.gsub! /([^\\])\\\]/, '\1<right-square-bracket>'
      while val.strip.length > 0 && iters < 100
        case
        when val =~ /--+/um
          val.sub!($&,'')
        when val =~ /\s*\{([^\}]+)\}\s*/um
          conds << $1
          val.sub!($&, '')
        when val =~ /\s*\[\^([^\]]+)\]\s*/um
          inputs ||= CharSet.new(:exclude)
          parse_combine_ranges($1, inputs)
          val.sub!($&, '')
        when val =~ /\s*\[([^\]]+)\]\s*/um
          inputs ||= CharSet.new(:include)
          parse_combine_ranges($1, inputs)
          val.sub!($&, '')
        when val =~ /^\s*\./um
          inputs ||= CharSet.new(:include)
          inputs << :any
          val.sub!($&, '')
        end
        iters += 1
      end
      return conds, inputs
    end

    ESCAPES = {'\t' => "\t", '\n' => "\n",
               '\r' => "\r", '\f' => "\f",
               '\b' => "\b", '\a' => "\a",
               '\e' => "\e", '\s' => " ",
               "\\\\" => '\\'}
    def parse_combine_ranges(raw, input)
      raw.gsub!(/\\[tnrfbaes\\]/){|m| ESCAPES[m]}
      raw.gsub!('<left-square-bracket>', '[')
      raw.gsub!('<right-square-bracket>', ']')
      if raw =~ /((?:.-.)*)((?:.)*)/um
        ranges = $1
        singles = $2
        if ranges.length > 0
          _, range, ranges = ranges.partition /.-./um
          input << range
        end while ranges.length > 0
        singles.scan(/./um).each{|s| input << s}
      end
    end
  end
end
