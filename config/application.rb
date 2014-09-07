require File.expand_path('../boot', __FILE__)
require 'rails/all'

Bundler.require(*Rails.groups)

module Pwtinvest
  class Application < Rails::Application
    config.time_zone = 'Brasilia'

    config.autoload_paths += %W[#{config.root}/lib]

    config.i18n.load_path += Dir[Rails.root.join("config/locales/**.*.yml").to_s]
    config.i18n.default_locale = :"pt-BR"
    config.i18n.enforce_available_locales = false

    config.encoding = "utf-8"

    config.filter_parameters += [:password]

    config.active_support.escape_html_entities_in_json = true

    config.generators.test_framework :rspec, :fixtures => false
    config.generators.assets = false

    config.assets.version = '1.0'
    config.assets.initialize_on_precompile = false

    config.active_record.whitelist_attributes = false

  end
end
