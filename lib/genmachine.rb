require 'genmachine/spec_parser'
require 'genmachine/char_set'

Dir[File.join(File.dirname(__FILE__),'genmachine','generators','*')].each do |fname|
  if File.directory? fname
    name = File.basename(fname)
    require "genmachine/generators/#{name}/#{name}"
  end
end

module GenMachine
  VERSION = File.exist?(File.join(File.dirname(__FILE__),'VERSION')) ? File.read(File.join(File.dirname(__FILE__),'VERSION')) : ""
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

    def version() VERSION end
  end
end
