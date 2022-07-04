module Support
  module Generators
    module Uploadable
      class ConfigGenerator < Rails::Generators::Base
        source_root File.join(__dir__, "templates")

      def generate_config
        copy_file "uploadable.rb", "config/initializers/support_uploadable.rb"
      end
      end
    end
  end
end