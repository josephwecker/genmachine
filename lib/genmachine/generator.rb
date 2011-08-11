module GenMachine
  module Generators
    class Generator
      TARGET_LANG = 'target-language'

      def initialize

      end

      def generate_class(classname, fname, language)
        @classname = classname
        f = File.new(fname, 'w+')
        f.write(@libraries[language].result(binding))
        f.close
      end

      def generate_executable(executablename, language)
        f = File.new(executablename, 'w+')
        f.write(@executables[language].result(binding))
        f.chmod(0755)
        f.close
      end

    end
  end
end
