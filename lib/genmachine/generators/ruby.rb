module GenMachine
  module Generators
    class RubyGenerator
      require 'erb'
      require 'genmachine/generators/helpers/ruby'
      include Generator
      include GenMachine::Helpers::Ruby
      include GenMachine::Helpers::General
      GENMACHINE_TARGET = 'ruby'

      def initialize(opts)
        @template_base = File.expand_path(File.dirname(__FILE__))+'/templates/ruby/'
        super(opts)
      end

      def generate_class
        library = ERB.new(IO.read(@template_base+'lib.erb.rb'),nil,'-')
        f = File.new(@class_fname, 'w+')
        f.write(library.result(binding))
        f.close
      end

      def generate_executable
        executable = ERB.new(IO.read(@template_base+'executable.erb'),nil,'-')
        f = File.new(@exe_fname, 'w+')
        f.write(executable.result(binding))
        f.chmod(0755)
        f.close
      end
    end
  end
end
