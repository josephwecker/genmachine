require 'strscan'
$KCODE="U"

class Integer
  def into(v); v << self end
  def reset!; :nop end
  def reset; :nop end
end

module <%= @classname %>
  def self.parse(str) Parser.new(str).parse end
  def self.parse_file(fname) Parser.new(IO.read(fname)).parse end


  class UArray < Array
    def into(v)
      return if size == 0
      v << self
    end
    def reset!; self.clear end
    def reset; d=dup;d.reset!;d end
  end

  class UHash < Hash
    def into(v) v << self end
    def <<(kv) k,v = kv; self[k] = v end
    def reset!; self.clear end
    def reset; d=dup; d.reset!; d end
  end

  class UString < String
    def into(v)
      return if size == 0
      v << self.dup
      reset!
    end

    def <<(v)
      begin; super([v].pack('U*'))
      rescue; super(v) end
    end
    def reset!; self.gsub! /./um,'' end
    def reset; d=dup;d.reset!;d end
  end

  class UNode
    attr_accessor :name, :m,:a,:c
    def initialize(params={})
      @m = params.delete(:m) || UHash.new
      @m[:sline] ||= params.delete(:sline)
      @m[:schr] ||= params.delete(:schr)
      @a= params.delete(:a) || UHash.new
      @c= params.delete(:c) || []
      @name = params.delete(:name)
    end
    def into(val) val << self end
    def <<(val) @c<<val end
    def [](key) @c[key] end
  end

  class Parser < StringScanner
    def init(source, opts={})
      opts ||= {}
      super ensure_encoding(source)
      @global = {}
    end

    def ensure_encoding(source)
      if defined?(::Encoding)
        if source.encoding == ::Encoding::ASCII_8BIT
          b = source[0, 4].bytes.to_a
          source =
            case
            when b.size>=4 && b[0]==0 && b[1]==0 && b[2]==0
              source.dup.force_encoding(::Encoding::UTF_32BE).encode!(::Encoding::UTF_8)
            when b.size>=4 && b[0]==0 && b[2]==0
              source.dup.force_encoding(::Encoding::UTF_16BE).encode!(::Encoding::UTF_8)
            when b.size>=4 && b[1]==0 && b[2]==0 && b[3]==0
              source.dup.force_encoding(::Encoding::UTF_32LE).encode!(::Encoding::UTF_8)
            when b.size>=4 && b[1]==0 && b[3]==0
              source.dup.force_encoding(::Encoding::UTF_16LE).encode!(::Encoding::UTF_8)
            else source.dup end
        else source = source.encode(::Encoding::UTF_8) end
        source.force_encoding(::Encoding::ASCII_8BIT)
      else
        b = source
        source =
          case
          when b.size >= 4 && b[0] == 0 && b[1] == 0 && b[2] == 0; Iconv.iconv('utf-8', 'utf-32be', b)
          when b.size >= 4 && b[0] == 0 && b[2] == 0; Iconv.iconv('utf-8', 'utf-16be', b)
          when b.size >= 4 && b[1] == 0 && b[2] == 0 && b[3] == 0; Iconv.iconv('utf-8', 'utf-32le', b)
          when b.size >= 4 && b[1] == 0 && b[3] == 0; Iconv.iconv('utf-8', 'utf-16le', b)
          else b end
      end
      return source
    end

    def parse
      reset
      @line = 1
      @pos = 1
      @leading = true
      @indent = 0
      @ast = <%= @spec_ast[0][0] %>
      return @ast
    end

    private

    def error(msg)
      $stderr.puts "#{msg} | line: #{@line} | char: #{@pos}"
    end

    def global_state(c)
      # Unicode newline characters & combinations
      # Plus leading space for indents.
      # Also tracks line and position for the AST
      @last_is_newline = @last_is_space = false
      case c
      when 0x0b, 0x0c, 0x85, 0x2028, 0x2029
        @last_is_newline = true; @line += 1; @pos = 1
        @leading = true; @indent = 0
      when 0x0a
        nc = peek(4).unpack('U')[0]
        if nc == 0x0d then getch; c = UString.new("\n\r") end
        @last_is_newline = true; @line += 1; @pos = 1
        @leading = true; @indent = 0
      when 0x0d
        nc = peek(4).unpack('U')[0]
        if nc == 0x0a then getch; c = UString.new("\r\n") end
        @last_is_newline = true; @line += 1; @pos = 1
        @leading = true; @indent = 0
      when 0x20,0x09
        @indent += 1 if @leading
        @last_is_space = true; @pos += 1
      else @leading = false; @pos += 1 end
      return @last_c = c
    end

    def nl?() return @last_is_newline end
    def space?() return @last_is_space end

    def nextchar
      if @fwd then @fwd = false; return @last_c
      else
        c = getch
        if c.nil?
          c = :eof
          @last_is_space = @last_is_newline = false
          return @last_c = c
        end
        return global_state(c.unpack('U')[0])
      end
    end

    def eof?() return @last_c == :eof end

<%- @spec_ast.each do |name, otype, args, cmds, first_state, states| -%>
  <%- args << "p=nil" -%>
  <%- args << "name='#{name}'" -%>
    def <%= name %>(<%= args.join(',') %>)
      <%- cmds.each do |c| -%>
      <%= rb_vars(c) %>
      <%- end -%>
      <%=STATE%>='<%= first_state %>'
      <%- if states.size > 1 or accumulates?(states) or makes_calls?(states) -%>
        <%- if otype == 'U' -%>
      s = UNode.new(:name=>name,:sline=>@line,:schr=>@pos)
        <%- elsif otype == '[]' -%>
      s = UArray.new
        <%- elsif otype == '{}' -%>
      s = UHash.new
        <%- end -%>
      <%- end -%>
      <%- accumulators(states).each do |_acc| -%>
      <%= _acc %> ||= UString.new
      <%- end -%>
      loop do
        <%= INPUT %> = nextchar
        <%- has_fallthru = false -%>
        <%- if eof_state?(states) -%>
        <%=STATE%> = '{eof}' if <%= INPUT %>==:eof
        <%- end -%>
        case <%=STATE%>
        <%- states.each do |st_name, clauses| -%>
        when '<%= st_name %>'
          <%- if clauses.size > 1 -%>
            case
            <%- clauses.each_with_index do |clause,i| -%>
              <%- cond = rb_conditional(clause,states,clauses) -%>
                <%- if cond == 'true' -%>
            else <%= rb_commands(clause,st_name) %>
                  <%- break -%>
                <%- else -%>
            when <%= cond %>; <%= rb_commands(clause,st_name) %>
                <%- has_fallthru = true if i == clauses.size-1 -%>
                <%- end -%>
            <%- end -%>
            end
          <%- else -%>
            <%- cond = rb_conditional(clauses[0],states,clauses) -%>
            <%- if cond == 'true' -%>
            <%= rb_commands(clauses[0],st_name) %>
            <%- else -%>
            if <%= cond %>
              <%= rb_commands(clauses[0],st_name) %>
            end
            <%- end -%>
          <%- end -%>
        <%- end -%>
        end
        <%- if has_fallthru -%>
        error("Unexpected #{<%= INPUT %>}")
        @fwd = true
        return
        <%- end -%>
      end
    end

<%- end -%>
  end
end
