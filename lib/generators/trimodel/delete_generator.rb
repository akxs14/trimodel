require 'rails/generators'

module Trimodel
  class DeleteGenerator < Rails::Generators::Base
    desc "Delete an existing triple model relationship"
    source_root File.expand_path(File.join(File.dirname(__FILE__), 'templates'))

    class_option :models, :type => :array, :desc => "The model triplet from where the association will be removed"

    def check_parameters
      if options[:models].class == NilClass
        puts "error: You need to give the models you want to associate"
        puts "e.g. rails g trimodel:new --models a b c"
      elsif options[:models].size != 3
        puts "error: Wrong number of models, they should be 3"
      end
    end

    def disable_lib_autoloading
      File.delete(Rails.root + "app/controllers/trimodel_application_controller.rb")
    end

    def rollback_migrations
    end

    def delete_migration_files
      list_and_delete_files options[:models][0], options[:models][1]
      list_and_delete_files options[:models][1], options[:models][2]
    end

    def delete_trimodel_file
      File.delete(Rails.root + "app/models/trimodel.rb")
    end

    private
      def list_and_delete_files model_a, model_b
        migration_files = Dir.entries(Rails.root + "db/migrate")
        for file in migration_files
          delete_migration_file file, model_a, model_b
        end
      end

      def delete_migration_file file, model_a, model_b
        if /_create_#{model_a.pluralize.downcase}_#{model_b.pluralize.downcase}_trimodel/ =~ file
          full_path = Rails.root.to_s + "/db/migrate/" + file
          File.delete(full_path)
        end
      end
  end
end
