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

    def rollback_migrations
      list_and_perform_on_files options[:models][0], options[:models][1] { |f,a,b| rollback_migration(f,a,b) }
      list_and_perform_on_files options[:models][1], options[:models][2] { |f,a,b| rollback_migration(f,a,b) }
    end

    def delete_migration_files
      list_and_perform_on_files options[:models][0], options[:models][1] { |f,a,b| delete_migration_file(f,a,b) }
      list_and_perform_on_files options[:models][1], options[:models][2] { |f,a,b| delete_migration_file(f,a,b) }
    end

    def delete_trimodel_file
      File.delete(Rails.root.to_s + "/config/initializers/trimodel_#{options[:models][0].downcase}_#{options[:models][1].downcase}_#{options[:models][2].downcase}.rb")
    end

    private
      def list_and_perform_on_files model_a, model_b
        migration_files = Dir.entries(Rails.root + "db/migrate")
        for file in migration_files
          yield(file, model_a, model_b)
        end
      end

      def delete_migration_file file, model_a, model_b
        if /_create_#{model_a.pluralize.downcase}_#{model_b.pluralize.downcase}_trimodel/ =~ file
          full_path = Rails.root.to_s + "/db/migrate/" + file
          File.delete(full_path)
        end
      end

      def rollback_migration file, model_a, model_b
        if /_create_#{model_a.pluralize.downcase}_#{model_b.pluralize.downcase}_trimodel/ =~ file
          %x[rake db:migrate:down VERSION=#{file[0,14]}]
        end
      end
  end
end
