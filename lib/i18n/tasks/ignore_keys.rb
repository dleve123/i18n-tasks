module I18n::Tasks::IgnoreKeys
  # whether to ignore the key. ignore_type one of :missing, :eq_base, :blank, :unused.
  # will apply global ignore rules as well
  def ignore_key?(key, ignore_type, locale = nil)
    key =~ ignore_pattern(ignore_type, locale)
  end

  # @param type [:missing, :eq_base, :unused] type
  # @param locale [String] only when type is :eq_base
  # @return [Regexp] a regexp that matches all the keys ignored for the type (and locale)
  def ignore_pattern(type, locale = nil)
    ((@ignore_patterns ||= HashWithIndifferentAccess.new)[type] ||= {})[locale] = begin
      global, type_ignore = config[:ignore].presence || [], config["ignore_#{type}"].presence || []
      if type_ignore.is_a?(Array)
        patterns = global + type_ignore
      elsif type_ignore.is_a?(Hash)
        # ignore per locale
        patterns = global + (type_ignore[:all] || []) +
            type_ignore.select { |k, v| k.to_s =~ /\b#{locale}\b/ }.values.flatten(1).compact
      end
      compile_patterns_re patterns
    end
  end
end