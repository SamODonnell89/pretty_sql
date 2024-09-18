# frozen_string_literal: true

module PrettySql
  class SqlFormatter
    INDENT_SIZE = 2
    NEW_LINE_KEYWORDS = %w[SELECT FROM WHERE GROUP HAVING ORDER LIMIT OFFSET].freeze
    INDENT_KEYWORDS = %w[SELECT WHERE].freeze
    UNINDENT_KEYWORDS = %w[FROM WHERE ORDER LIMIT OFFSET].freeze
    JOIN_KEYWORDS = %w[JOIN INNER LEFT RIGHT FULL CROSS].freeze
    MULTI_WORD_JOIN_TYPES = [
      "INNER JOIN", "LEFT JOIN", "RIGHT JOIN", "FULL JOIN",
      "LEFT OUTER JOIN", "RIGHT OUTER JOIN", "FULL OUTER JOIN"
    ].freeze

    attr_reader :formatted_sql

    def initialize(payload)
      @payload = payload
      @sql = replace_placeholders
      @tokens = tokenize_sql
    end

    def format_sql
      @formatted_sql = format_tokens
      @formatted_sql = handle_subqueries(@formatted_sql)
      @formatted_sql = join_multi_word_clauses(@formatted_sql)
      @formatted_sql = handle_multi_word_joins(@formatted_sql)
      @formatted_sql.strip
    end

    def colorize
      "\e[#{PrettySql.color_code}m#{@formatted_sql}\e[0m"
    end

    private

    attr_reader :payload, :sql, :tokens

    def replace_placeholders
      sql = payload[:sql]
      binds = payload[:binds]
      type_casted_binds = payload[:type_casted_binds]

      return sql unless binds&.present? && type_casted_binds&.present?

      binds.zip(type_casted_binds).each_with_index do |(_, _), i|
        value = type_casted_binds[i]
        value = "'#{value}'" if value.is_a?(String)
        sql = sql.sub(/\$#{i + 1}/, value.to_s)
      end

      sql
    end

    def tokenize_sql
      sql.gsub(/\s+/, " ").strip.split
    end

    def format_tokens
      current_indents = 0

      tokens.each_with_object([]) do |token, result|
        upper_token = token.upcase

        if NEW_LINE_KEYWORDS.include?(upper_token) || JOIN_KEYWORDS.include?(upper_token)
          current_indents -= 1 if UNINDENT_KEYWORDS.include?(upper_token) && current_indents.positive?
          result << "\n#{" " * INDENT_SIZE * [current_indents, 0].max}#{token}"
          current_indents += 1 if INDENT_KEYWORDS.include?(upper_token)
        elsif upper_token == "AND"
          result << "\n#{" " * INDENT_SIZE * [current_indents, 0].max}#{token}"
        else
          result << token
        end
      end.join(" ")
    end

    def handle_subqueries(formatted_sql)
      formatted_sql.gsub("(SELECT", "\n#{" " * INDENT_SIZE}(SELECT")
    end

    def join_multi_word_clauses(formatted_sql)
      JOIN_KEYWORDS.each do |join_type|
        formatted_sql.gsub!(/\n\s*(#{join_type})\s+(\w+)\s+JOIN/, "\n#{join_type} \\2 JOIN")
      end
      formatted_sql
    end

    def handle_multi_word_joins(formatted_sql)
      MULTI_WORD_JOIN_TYPES.each do |join_type|
        formatted_sql.gsub!(/\n\s*#{join_type.gsub(" ", '\s+')}/, "\n#{join_type}")
      end
      formatted_sql
    end
  end
end
