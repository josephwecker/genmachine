module GenMachine
  module Generators
    class RubyGenerator
      require 'erb'
      require 'genmachine/generators/generator'
      require 'genmachine/generators/general_helper'
      require 'genmachine/generators/ruby/helper'
      include Generator
      include GenMachine::Helpers::Ruby
      include GenMachine::Helpers::General
      GENMACHINE_TARGET = 'ruby'

      def initialize(opts)
        @template_base = File.dirname(__FILE__) + '/'
        super(opts)
      end

      def generate_class
        library = ERB.new(IO.read(@template_base+'lib.erb.rb'),nil,'-')
        f = File.new(File.join(@output_dir,@class_fname), 'w+')
        f.write(library.result(binding))
        f.close
      end

      def generate_executable
        return unless @gen_executable
        executable = ERB.new(IO.read(@template_base+'executable.erb'),nil,'-')
        f = File.new(File.join(@output_dir,@exe_fname), 'w+')
        f.write(executable.result(binding))
        f.chmod(0755)
        f.close
      end
    end
  end
end
