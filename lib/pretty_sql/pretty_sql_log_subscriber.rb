require "active_record/log_subscriber"
require_relative "sql_formatter"

class PrettySqlLogSubscriber < ActiveRecord::LogSubscriber
  def initialize
    super
    PrettySql.enabled = true
  end

  def sql(event)
    return unless PrettySql.enabled
    return unless logger.info? || logger.debug?
    return if ignore_payload?(event.payload)

    payload = event.payload
    name = "#{payload[:name]} (#{event.duration.round(1)}ms)"

    name = colorize_payload_name(name, payload[:name])
    format_sql!(payload)

    # info "#{name}  \n\e[1m\e[34m#{format!(payload)}\e[0m"
    info "#{name}  \n#{@sql_formatter.colorize}"
    explain_analyse!
  end

  def format_sql!(payload)
    @sql_formatter = PrettySql::SqlFormatter.new(payload)
    @sql_formatter.format_sql
  end

  def colorize_sql!
    @sql_formatter.colorize
  end

  private

  IGNORED_PAYLOADS = %w[SCHEMA EXPLAIN]
  EXPLAINED_SQLS = %r{\A\s*(/\*.*\*/)?\s*(with|select|update|delete|insert)\b}i

  def ignore_payload?(payload)
    payload[:exception] ||
      payload[:cached] ||
      IGNORED_PAYLOADS.include?(payload[:name]) ||
      !payload[:sql].match?(EXPLAINED_SQLS)
  end

  def cached_query?(payload)
    payload[:cached] || payload[:name] == "CACHE"
  end

  def explain_analyse!
    result = ActiveRecord::Base.connection.execute("EXPLAIN ANALYZE #{@sql_formatter.formatted_sql}")
    output = []
    result.each do |row|
      output << row.values.dig(0)
    end

    puts format_explain_output(output)
  end

  def format_explain_output(explain_output)
    # TODO: Implement
    explain_output
  end
end
