require 'rails/generators'

module Trimodel
  class NewGenerator < Rails::Generators::Base
    desc "Creates a new triple model relationship"
    source_root File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
  end
end
