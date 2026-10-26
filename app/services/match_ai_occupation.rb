# Matching is scoped to one source PDF. RAPIDS suffix normalization here is only
# for selecting a comparison, never for changing stored codes or score rules.
class MatchAIOccupation
  def self.call(attempts, standard, allow_single_fallback: true, occupation_response: {})
    attempts = attempts.to_a
    direct = attempts.select { |attempt| standard.id.present? && attempt.occupation_standard_id == standard.id }
    return direct.first if direct.one?

    successful = attempts.select { |attempt| attempt.occupation_standard_id.present? }
    code = normalize_code(standard.rapids_code)
    if code.present?
      exact = successful.select { |attempt| normalize_code(attempt.occupation_standard.rapids_code) == code }
      return choose(exact, standard, occupation_response) if exact.any?

      stem = code[/\A\d+/]
      related = successful.select { |attempt| stem && normalize_code(attempt.occupation_standard.rapids_code)[/\A\d+/] == stem }
      return choose(related, standard, occupation_response) if related.any?
    end

    titles = successful.select { |attempt| normalize_title(attempt.occupation_standard.title) == normalize_title(standard.title) }
    return titles.first if titles.one?

    baseline_words = normalize_title(standard.title).split
    aliases = successful.select do |attempt|
      [attempt.occupation_standard.title, attempt.occupation_standard.existing_title].compact.any? do |title|
        words = normalize_title(title).split
        words.length >= 2 && (words - baseline_words).empty?
      end
    end
    return aliases.first if aliases.one?
    return unless allow_single_fallback && successful.one?

    response = successful.first.parsed_response
    successful.first unless response["singleOccupation"] == false || response["documentOccupationCount"].to_i > 1
  end

  def self.normalize_code(code)
    code.to_s.upcase.delete(" ").sub(/\A(\d+)/) { |digits| digits.rjust(4, "0") }
  end

  def self.normalize_title(title)
    title.to_s.downcase.gsub(/\([^)]*\)/, " ").sub(/\s+(?:competency[ -]based|time[ -]based|hybrid)\s*\z/, "").scan(/[a-z0-9]+/).join(" ")
  end

  def self.choose(attempts, standard, response)
    return attempts.first if attempts.one?

    if response["appendixLabel"].present?
      labels = attempts.select { |attempt| attempt.parsed_response["appendixLabel"].to_s.strip.casecmp?(response["appendixLabel"].to_s.strip) }
      return labels.first if labels.one?
      attempts = labels if labels.any?
    end
    if standard.organization.present?
      organizations = attempts.select { |attempt| attempt.parsed_response["organization"].to_s.strip.casecmp?(standard.organization.title.to_s.strip) }
      return organizations.first if organizations.one?
      attempts = organizations if organizations.any?
    end
    exact_titles = attempts.select { |attempt| attempt.occupation_standard.title.to_s.downcase.scan(/[a-z0-9]+/) == standard.title.to_s.downcase.scan(/[a-z0-9]+/) }
    return exact_titles.first if exact_titles.one?

    if standard.ojt_type.present?
      approaches = attempts.select { |attempt| attempt.occupation_standard.ojt_type == standard.ojt_type }
      return approaches.first if approaches.one?
      attempts = approaches if approaches.any?
    end
    titles = attempts.select { |attempt| normalize_title(attempt.occupation_standard.title) == normalize_title(standard.title) }
    titles.first if titles.one?
  end
  private_class_method :choose
end
