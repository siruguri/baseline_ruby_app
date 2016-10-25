require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

require 'yaml'
#require 'pry-stack_explorer'
require 'active_support/time'

Mongoid.load!("config/mongoid.yml", :development)
appconfig = YAML::load(File.open('config/app.yml')) if File.exists?('config/app.yml')
class App
  def self.root
    Pathname.new(File.dirname(__FILE__)).realpath.to_s
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

Dir.glob(File.join('models', '**', '*rb')).each { |f| require_relative f }
Dir.glob(File.join('lib', '**', '*rb')).each { |f| require_relative f }

App.config(appconfig)

puts RunRecord.count
r = RunRecord.new run_tag: 'test', run_at: Time.now
r.save!
puts " -> #{RunRecord.count}"

