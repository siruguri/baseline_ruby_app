require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

require 'yaml'
#require 'pry-stack_explorer'
require 'active_support/time'

Mongoid.load!("config/mongoid.yml", :development)
appconfig = YAML::load(File.open('config/app.yml')) if File.exists?('config/app.yml')

module App
  class App
    attr_reader :args

    def self.multiplex(inst)
      sequence = inst.args[:commands] || 'test1,test2'
      syms = sequence.split(',').map { |s| s.to_sym }
      syms.each do |s|
        inst.send s
      end
    end
    
    def self.root
      Pathname.new(File.dirname(__FILE__)).realpath.to_s
    end

    def self.args=(list = [])
      @args = list
    end
    
    def self.config(cfg=nil)
      if cfg.nil?
        return @_cfg
      else
        @_cfg={}
        cfg.keys.each do |k|
          @_cfg[k]=cfg[k]
        end
        
        # Defaults
      end
    end
  end
end

Dir.glob(File.join('models', '**', '*rb')).each { |f| require_relative f }
Dir.glob(File.join('lib', '**', '*rb')).each { |f| require_relative f }
Dir.glob(File.join('app', '**', '*rb')).each { |f| require_relative f }

App::App.config(appconfig)

a = App::App.new
a.parse_cli_args
App::App.multiplex a # defaults to test1, test2 (both in app/test_1.rb)
