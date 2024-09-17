# frozen_string_literal: true

require_relative "pretty_sql/version"
require_relative "pretty_sql/pretty_sql_log_subscriber"
require_relative "pretty_sql/railtie" if defined?(Rails)

module PrettySql
  class Error < StandardError; end

  class << self
    attr_accessor :enabled

    def configure
      yield self
    end

    def enable!
      self.enabled = true
      ActiveSupport::Notifications.unsubscribe("sql.active_record")
      PrettySqlLogSubscriber.attach_to :active_record
    end

    def disable!
      self.enabled = false
      ActiveSupport::Notifications.unsubscribe("sql.active_record")
      ActiveRecord::LogSubscriber.attach_to :active_record
    end
  end
end
