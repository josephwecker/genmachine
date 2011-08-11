require 'genmachine/spec_parser'
require 'genmachine/generator'
require 'genmachine/generators/helpers/general'

Dir[File.join(File.dirname(__FILE__),'genmachine','generators','*.rb')].each do |fname|
  name = File.basename(fname)
  require "genmachine/generators/#{name}"
end

module GenMachine
  class << self
    def languages
      GenMachine::Generators.constants.map{|const| const.to_underscored}.delete_if{|c| c=='generator'}
    end
  end
end
