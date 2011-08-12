require 'genmachine/spec_parser'
require 'genmachine/generator'
require 'genmachine/generators/helpers/general'
require 'genmachine/char_set'

Dir[File.join(File.dirname(__FILE__),'genmachine','generators','*.rb')].each do |fname|
  name = File.basename(fname)
  require "genmachine/generators/#{name}"
end

module GenMachine
  class << self
    def generators
      Generators.constants.reduce({}) do |langs,const|
        klass = Generators.const_get(const)
        if klass.const_defined?('GENMACHINE_TARGET')
          langs[klass::GENMACHINE_TARGET] = klass
        end
        langs
      end
    end
  end
end
