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

    def create_trimodel_file
      File.open(Rails.root + "config/initializers/trimodel.rb",
        File::CREAT|File::RDWR) do |f|
          add_one_asoc_to_model f, options[:models][0], options[:models][1]
          add_two_asocs_to_model f, options[:models][1], options[:models][0], options[:models][2]
          add_one_asoc_to_model f, options[:models][2], options[:models][1]
      end
    end

    private
      def add_one_asoc_to_model file, model_a, model_b
        file.write(create_class_definition(model_a))
        file.write(add_n_to_n_association(model_b))
        file.write(add_end)
      end

      def add_two_asocs_to_model file, model_a, model_b, model_c
        file.write(create_class_definition(model_a))
        file.write(add_n_to_n_association(model_b))
        file.write(add_n_to_n_association(model_c))
        file.write(add_end)
      end

      def create_class_definition model
        "class #{model} < ActiveRecord::Base\n"
      end

      def add_n_to_n_association model_b
        "  has_and_belongs_to_many :#{model_b.pluralize.downcase}\n"
      end

      def add_iterator_method bridge_model, target_model

      end

      def add_end
        "end\n"
      end

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
