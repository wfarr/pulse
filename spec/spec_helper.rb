$LOAD_PATH.unshift 'lib/'

require 'rubygems'
require 'isolate/scenarios'
require 'isolate/now'
require 'active_support'
require 'action_pack'
require 'action_controller'
require 'action_controller/test_process'
require 'activerecord'
require 'rails/version'
require 'pulse'

#mock out some rails related stuff

RAILS_ROOT='.'

def require_dependency(foo)
  nil
end

class ApplicationController < ActionController::Base
  helper :all
end

def params_from(method, path)
  ActionController::Routing::Routes.recognize_path(path, :method => method)
end

begin
  require 'spec'
  require 'spec/rails'
rescue LoadError
  gem 'rspec'
  gem 'rspec-rails'
  require 'spec'
  require 'spec/rails'
end