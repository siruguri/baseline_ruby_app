require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

require 'yaml'
#require 'pry-stack_explorer'
require 'active_support/time'

dbconfig = YAML::load(File.open('config/database.yml'))
appconfig = YAML::load(File.open('config/app.yml')) if File.exists?('config/app.yml')
ActiveRecord::Base.establish_connection(dbconfig)

Dir.glob(File.join('init', '**', '*rb')).each { |f| require_relative f }
Dir.glob(File.join('models', '**', '*rb')).each { |f| require_relative f }
Dir.glob(File.join('lib', '**', '*rb')).each { |f| require_relative f }
Dir.glob(File.join('app', '**', '*rb')).each { |f| require_relative f }

App::App.config appconfig
a = App::App.new
a.parse_cli_args
App::App.multiplex a
