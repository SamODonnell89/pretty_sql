require "pretty_sql"
require "rails/railtie"

module PrettySql
  class Railtie < Rails::Railtie
    config.pretty_sql = ActiveSupport::OrderedOptions.new

    initializer "pretty_sql.configure_rails_initialization" do |app|
      app.config.pretty_sql.enabled = false if app.config.pretty_sql.enabled.nil?

      PrettySql.configure do |config|
        config.enabled = app.config.pretty_sql.enabled
      end

      PrettySql.enable! if app.config.pretty_sql.enabled
    end

    # This allows users to enable PrettySql in their Rails configuration
    def self.enable
      config.pretty_sql.enabled = true
    end
  end
end
