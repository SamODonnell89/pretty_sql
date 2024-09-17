require "active_record/log_subscriber"

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

    info "#{name}  \n\e[1m\e[34m#{format_sql(payload)}\e[0m"
  end

  def format_sql(payload)
    sql = replace_placeholders(payload)
    tokens = tokenize_sql(sql)
    formatted_sql = format_tokens(tokens)
    handle_subqueries(formatted_sql)
    join_multi_word_clauses(formatted_sql)
    handle_multi_word_joins(formatted_sql)
    formatted_sql.strip
  end

  private

  def replace_placeholders(payload)
    sql = payload[:sql]
    binds = payload[:binds]
    type_casted_binds = payload[:type_casted_binds]

    if binds.present? && type_casted_binds.present?
      binds.zip(type_casted_binds).each_with_index do |(col, _), i|
        value = type_casted_binds[i]
        value = "'#{value}'" if value.is_a?(String)
        sql = sql.sub(/\$#{i + 1}/, value.to_s)
      end
    end

    sql
  end

  def tokenize_sql(sql)
    sql.gsub(/\s+/, " ").strip.split
  end

  def format_tokens(tokens)
    current_indents = 0
    indent_size = 2

    new_line_keywords = %w[SELECT FROM WHERE GROUP HAVING ORDER LIMIT OFFSET]
    indent_keywords = %w[SELECT WHERE]
    unindent_keywords = %w[FROM WHERE ORDER LIMIT OFFSET]
    join_keywords = %w[JOIN INNER LEFT RIGHT FULL CROSS]

    tokens.map do |token|
      upper_token = token.upcase

      if new_line_keywords.include?(upper_token) || join_keywords.include?(upper_token)
        current_indents -= 1 if unindent_keywords.include?(upper_token) && current_indents > 0
        result = "\n" + (" " * indent_size * [current_indents, 0].max) + token
        current_indents += 1 if indent_keywords.include?(upper_token)
        result
      elsif token.upcase == "AND"
        "\n" + (" " * indent_size * [current_indents, 0].max) + token
      else
        token
      end
    end.join(" ")
  end

  def handle_subqueries(formatted_sql)
    formatted_sql.gsub(/\(SELECT/, "\n#{" " * 2}(SELECT")
  end

  def join_multi_word_clauses(formatted_sql)
    join_keywords = %w[JOIN INNER LEFT RIGHT FULL CROSS]
    join_keywords.each do |join_type|
      formatted_sql.gsub!(/\n\s*(#{join_type})\s+(\w+)\s+JOIN/, "\n#{join_type} \\2 JOIN")
    end
  end

  def handle_multi_word_joins(formatted_sql)
    join_types = [
      "INNER JOIN",
      "LEFT JOIN",
      "RIGHT JOIN",
      "FULL JOIN",
      "LEFT OUTER JOIN",
      "RIGHT OUTER JOIN",
      "FULL OUTER JOIN"
    ]

    join_types.each do |join_type|
      formatted_sql.gsub!(/\n\s*#{join_type.gsub(" ", '\s+')}/, "\n#{join_type}")
    end

    formatted_sql
  end

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

  def explain_analyse(query)
    result = ActiveRecord::Base.connection.execute("EXPLAIN ANALYZE #{query}")
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
