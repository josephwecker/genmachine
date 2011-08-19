module GenMachine
  module Generators
    module Generator
      def initialize(opts={})
        opts ||= {}
        @spec_ast       = opts.delete(:spec_ast)
        @gen_executable = opts.delete(:executable)
        @classname      = opts.delete(:classname)  || 'MiscParser'
        @test_file      = opts.delete(:test_file)
        @output_dir     = opts.delete(:output_dir) || './'
        @class_fname    = opts.delete(:class_fname)|| @classname.to_underscored
        @exe_fname      = opts.delete(:exe_fname)  || @classname.sub(/parser$/i,'').to_underscored
        @debug          = opts.delete(:debug)
        @gen_executable = false if @gen_executable.nil?
        @debug          = false if @debug.nil?
        raise ArgumentError, "Must include the table specification data (:spec_ast)" if @spec_ast.nil?
      end

      def generate_class
        puts "TODO: Generate class (#{@classname}): #{@class_fname}" if @debug
      end

      def generate_executable
        return unless @gen_executable
        puts "TODO: Generate executable: #{@exe_fname}" if @debug
      end

      def run_test
        return if @test_file.nil?
        puts "TODO: Run test" if @debug
      end
    end
  end
end
