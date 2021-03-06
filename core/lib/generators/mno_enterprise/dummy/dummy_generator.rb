require 'rails/generators'
require 'rails/generators/rails/app/app_generator'

module MnoEnterprise
  class DummyGenerator < Rails::Generators::Base
    desc "Creates blank Rails application, installs MNOE"

    class_option :lib_name, default: ''
    class_option :database, default: ''

    def self.source_paths
      paths = self.superclass.source_paths
      paths << File.expand_path('../templates', __FILE__)
      paths.flatten
    end

    def clean_up
      remove_directory_if_exists(dummy_path)
    end

    PASSTHROUGH_OPTIONS = [
      :skip_active_record, :skip_javascript, :database, :javascript, :quiet, :pretend, :force, :skip
    ]

    def generate_test_dummy
       # calling slice on a Thor::CoreExtensions::HashWithIndifferentAccess
      # object has been known to return nil
      opts = {}.merge(options).slice(*PASSTHROUGH_OPTIONS)
      opts[:database] = 'sqlite3' if opts[:database].blank?
      opts[:force] = true
      opts[:skip_bundle] = true

      say "Generating dummy Rails application..."
      invoke Rails::Generators::AppGenerator,
        [ File.expand_path(dummy_path, destination_root) ], opts
    end

    def test_dummy_config
      @lib_name = options[:lib_name]
      @database = options[:database]

      template "rails/database.yml", "#{dummy_path}/config/database.yml", force: true
      template "rails/boot.rb.erb", "#{dummy_path}/config/boot.rb", force: true
      template "rails/application.rb.erb", "#{dummy_path}/config/application.rb", force: true
      template "rails/routes.rb", "#{dummy_path}/config/routes.rb", force: true
      template "rails/test-env.rb", "#{dummy_path}/config/environments/test.rb", force: true
    end

    # Overwrite mnoe less file required by asset pipeline
    def test_dummy_frontend
      if defined?(MnoEnterprise::Frontend)
        create_file("#{dummy_path}/app/assets/stylesheets/main.less", force: true)
      end
    end

    def test_dummy_clean
      inside dummy_path do
        remove_file ".gitignore"
        remove_file "doc"
        remove_file "Gemfile"
        remove_file "lib/tasks"
        remove_file "app/assets/images/rails.png"
        remove_file "public/index.html"
        remove_file "public/robots.txt"
        remove_file "README"
        remove_file "test"
        remove_file "vendor"
      end
    end

    attr :lib_name
    attr :database

    protected

    def dummy_path
      ENV['DUMMY_PATH'] || 'spec/dummy'
    end

    def module_name
      'Dummy'
    end

    def application_definition
      @application_definition ||= begin

        dummy_application_path = File.expand_path("#{dummy_path}/config/application.rb", destination_root)
        unless options[:pretend] || !File.exists?(dummy_application_path)
          contents = File.read(dummy_application_path)
          contents[(contents.index("module #{module_name}"))..-1]
        end
      end
    end
    alias :store_application_definition! :application_definition

    def remove_directory_if_exists(path)
      remove_dir(path) if File.directory?(path)
    end

    def gemfile_path
      '../../../../Gemfile'
    end

  end
end
