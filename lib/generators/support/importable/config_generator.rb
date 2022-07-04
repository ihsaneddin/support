module Support
  module Generators
    module Importable
      class ConfigGenerator < Rails::Generators::Base
        source_root File.join(__dir__, "templates")

      def generate_config
        copy_file "importable.rb", "config/initializers/support_importable.rb"
      end
      end
    end
  end
end