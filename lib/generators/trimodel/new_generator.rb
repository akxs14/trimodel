require 'rails/generators'
require 'active_support/inflector'
require 'rake'

module Trimodel
  class NewGenerator < Rails::Generators::Base
    desc "Creates a new triple model relationship"
    source_root File.expand_path(File.join(File.dirname(__FILE__), 'templates'))

    class_option :models, :type => :array, :desc => "The triplet model that will be associated"

    def check_parameters
      if options[:models].class == NilClass
        puts "error: You need to give the models you want to associate"
        puts "e.g. rails g trimodel:new --models a b c"
      elsif options[:models].size != 3
        puts "error: Wrong number of models, they should be 3"
      end
    end

    #create app/controllers/trimodel_application_controller.rb 
    #where the automatic load of lib/trimodel.rb is added
    #in development mode
    def enable_lib_autoloading
      code= <<-eos
class ApplicationController < ActionController::Base
  RELOAD_LIBS = Dir[Rails.root + 'lib/trimodel.rb'] if Rails.env.development?
  before_filter :_reload_libs, :if => :_reload_libs?

  def _reload_libs
    RELOAD_LIBS.each do |lib|
      require_dependency lib
    end
  end

  def _reload_libs?
    defined? RELOAD_LIBS
  end
end
eos
      File.open(Rails.root + "app/controllers/trimodel_application_controller.rb",
        File::CREAT|File::RDWR) do |fi|
        fi.write(code)
      end
    end

    def create_migration_files
      create_migration_file options[:models][0], options[:models][1]
      #need to wait so the timestamp has a different value
      #and forms a correct migration file name
      sleep(1)
      create_migration_file options[:models][1], options[:models][2]
    end

    def perform_migrations
      %x[rake db:migrate]
    end

    #create lib/trimodel.rb and where you open classes
    #add the new associations and any other needed method
    def create_trimodel_file
      File.open(Rails.root + "app/models/trimodel.rb",
        File::CREAT|File::RDWR) do |f|
          f.write("hello")
      end
    end

    def create_model_associations
    end

    private
      def create_migration_file model_a, model_b
        path = Rails.root.to_s
        path << "/db/migrate/#{create_timestamp}_"
        path << "create_#{model_a.pluralize.downcase}_"
        path << "#{model_b.pluralize.downcase}_trimodel_join_table.rb" 
        File.open(path,File::CREAT|File::RDWR) do |fi|
            fi.write(write_migration_code(model_a, model_b))
        end
      end

      def create_timestamp
        Time.now.utc.to_s.gsub('-','').gsub(':','').gsub(' ','')[0..-4]
      end

      def write_migration_code model_a, model_b
        code=<<-eos
class Create#{model_a.pluralize}#{model_b.pluralize}TrimodelJoinTable < ActiveRecord::Migration
  def self.up
    create_table :#{model_a.pluralize.downcase}_#{model_b.pluralize.downcase}, :id => false do |t|
      t.integer :#{model_a.downcase}_id
      t.integer :#{model_b.downcase}_id
    end
  end

  def self.down
    drop_table :#{model_a.pluralize.downcase}_#{model_b.pluralize.downcase}
  end
end
eos
        code
      end
  end
end
