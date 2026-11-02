# A conservative source audit, not an inference from the benchmark answer.
# It intentionally leaves implicit approaches and shared documents for review.
class OJTTypeEvidence
  Result = Data.define(:ojt_type, :evidence, :reason)
  LABEL = /time[ -]based|competency[ -]based|hybrid/i
  CHECKED_CHOICE = /[☒☑]\s*(#{LABEL})/
  EXPLICIT_STATEMENT = /This is a (#{LABEL}) apprenticeship standard\./i
  EXPLICIT_LABEL = /(?:type of (?:training|apprenticeship|occupation)|apprenticeship (?:type|approach))\s*:\s*(#{LABEL})/i

  def initialize(text:, single_occupation:)
    @text = text
    @single_occupation = single_occupation
  end

  def call
    return Result.new(ojt_type: nil, evidence: [], reason: "Occupation-specific source boundaries require review") unless @single_occupation

    evidence = []
    pages = @text.to_s.split("\f")
    if pages.one? && @text.start_with?("--- Page 1 ---\n")
      pages = @text.split(/^--- Page \d+ ---\n/).drop(1)
    end
    pages.each_with_index do |page, index|
      lines = page.lines
      lines.each_with_index do |line, line_index|
        if line.scan(LABEL).size == 1 && (label = line.match(EXPLICIT_LABEL))
          evidence << entry(label[1], line.strip, index + 1, "explicit_label")
        end
        choices = line.match?(/time[ -]based/i) && line.match?(/competency[ -]based/i) && line.match?(/hybrid/i)
        context = lines[[line_index - 5, 0].max..line_index].join
        next unless choices || context.match?(/apprenticeship\s+(?:approach|type)|type\s+of\s+(?:occupation|apprenticeship)/i)

        line.scan(CHECKED_CHOICE) do |match|
          evidence << entry(match.first, line.strip, index + 1, "checked_choice")
        end
      end
      normalized = page.gsub(/\s+/, " ")
      normalized.scan(EXPLICIT_STATEMENT) do |match|
        quote = Regexp.last_match[0]
        evidence << entry(match.first, quote, index + 1, "explicit_statement")
      end
      normalized.scan(/The term of (?:the occupation|apprenticeship) is based on the apprentice[’']s demonstration of (?:the mastery of )?competencies[^.]*\./i) do
        quote = Regexp.last_match[0]
        # A second, mandatory OJL time requirement could make this hybrid.
        next if quote.match?(/\b(?:OJL|OJT|on.the.job)\b/i)

        evidence << entry("competency", quote, index + 1, "completion_requirement")
      end
    end
    types = evidence.map { |item| item[:ojt_type] }.uniq
    type = types.first if types.one?
    reason = if types.empty?
      "No unambiguous approach selection or completion requirement found; do not infer from hours, task lists, or code suffixes alone"
    elsif types.many?
      "Conflicting source approaches require review"
    else
      "Supported by occupation-specific source evidence"
    end
    Result.new(ojt_type: type, evidence: evidence, reason: reason)
  end

  private

  def entry(label, quote, page, kind)
    type = case label.downcase
    when /competency/ then "competency"
    when /hybrid/ then "hybrid"
    else "time"
    end
    {ojt_type: type, page: page, kind: kind, quote: quote}
  end
end
