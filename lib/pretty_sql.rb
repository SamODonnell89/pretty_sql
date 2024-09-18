# frozen_string_literal: true

require_relative "pretty_sql/version"
require_relative "pretty_sql/pretty_sql_log_subscriber"
require_relative "pretty_sql/railtie" if defined?(Rails)

module PrettySql
  class Error < StandardError; end

  COLORS = {
    true => "38",
    :blue => "34",
    :light_red => "1;31",
    :black => "30",
    :purple => "35",
    :light_green => "1;32",
    :red => "31",
    :cyan => "36",
    :yellow => "1;33",
    :green => "32",
    :gray => "37",
    :light_blue => "1;34",
    :brown => "33",
    :dark_gray => "1;30",
    :light_purple => "1;35",
    :white => "1;37",
    :light_cyan => "1;36"
  }.freeze

  DEFAULT_CONFIG = {
    enabled: false,
    auto_explain_enabled: false,
    sql_output_colour: :light_blue,
    auto_explain_threshold_in_seconds: 0.005 # 5ms (for testing only, change to a higher value later)
  }.freeze

  class << self
    attr_accessor :enabled, :auto_explain_enabled, :sql_output_colour, :auto_explain_threshold_in_seconds

    def configure
      config
      yield self
    end

    def config
      config = ActiveSupport::OrderedOptions.new
      DEFAULT_CONFIG.each do |key, default_value|
        config[key] = send(key) || default_value
      end
      config
    end

    def enable!
      self.enabled = true
      attach!
    end

    def disable!
      self.enabled = false
      detach!
    end

    def enabled?
      !!enabled
    end

    def auto_explain_enabled?
      !!auto_explain_enabled
    end

    def attach!
      ActiveSupport::Notifications.unsubscribe("sql.active_record")
      PrettySqlLogSubscriber.attach_to :active_record
    end

    def detach!
      ActiveSupport::Notifications.unsubscribe("sql.active_record")
      ActiveRecord::LogSubscriber.attach_to :active_record
    end

    def color_code
      COLORS[sql_output_colour] || COLORS[:blue]
    end
  end
end
