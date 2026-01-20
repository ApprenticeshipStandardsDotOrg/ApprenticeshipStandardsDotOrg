class CompareAIToHuman
  def initialize(occupation_standard)
    @occupation_standard = occupation_standard
    @open_ai_import = occupation_standard.open_ai_import
    @human_work_processes = occupation_standard.work_processes.includes(:competencies).to_a
    @human_related_instructions = occupation_standard.related_instructions.to_a
  end

  def call
    return nil unless @open_ai_import.present?
    return nil unless @open_ai_import.response.present?

    ai_data = JSON.parse(@open_ai_import.response)
    ai_work_processes = extract_ai_work_processes(ai_data)
    ai_related_instructions = extract_ai_related_instructions(ai_data)

    work_processes_score = compare_work_processes(ai_work_processes, @human_work_processes)
    related_instructions_score = compare_related_instructions(ai_related_instructions, @human_related_instructions)

    overall_score = calculate_overall_score(work_processes_score, related_instructions_score)

    work_processes_details = generate_work_processes_details(ai_work_processes, @human_work_processes)
    related_instructions_details = generate_related_instructions_details(ai_related_instructions, @human_related_instructions)

    result = AIComparisonResult.find_or_initialize_by(occupation_standard: @occupation_standard)
    result.assign_attributes(
      work_processes_score: work_processes_score,
      related_instructions_score: related_instructions_score,
      overall_score: overall_score,
      work_processes_comparison_details: work_processes_details.to_json,
      related_instructions_comparison_details: related_instructions_details.to_json,
      flagged_by_system: overall_score < 70
    )
    result.update_review_status
    result
  end

  private

  def extract_ai_work_processes(ai_data)
    ai_data["workProcesses"] || []
  end

  def extract_ai_related_instructions(ai_data)
    ai_data["relatedInstructions"] || []
  end

  def compare_work_processes(ai_work_processes, human_work_processes)
    return 0.0 if ai_work_processes.empty? && human_work_processes.empty?
    return 0.0 if ai_work_processes.empty? || human_work_processes.empty?

    # Normalize titles for comparison
    ai_titles = normalize_titles(ai_work_processes.map { |wp| wp["title"] || "" })
    human_titles = normalize_titles(human_work_processes.map(&:title))

    # Calculate count similarity
    count_similarity = calculate_count_similarity(ai_work_processes.length, human_work_processes.length)

    # Calculate title matching similarity using fuzzy matching
    title_similarity = calculate_title_similarity(ai_titles, human_titles)

    # Calculate description similarity for matched work processes
    description_similarity = calculate_description_similarity(ai_work_processes, human_work_processes)

    # Calculate competencies similarity (for competency/hybrid types)
    competencies_similarity = calculate_competencies_similarity(ai_work_processes, human_work_processes)

    # Weighted average: 30% count, 40% titles, 20% descriptions, 10% competencies
    score = (
      count_similarity * 0.3 +
      title_similarity * 0.4 +
      description_similarity * 0.2 +
      competencies_similarity * 0.1
    ) * 100

    score.round(2)
  end

  def compare_related_instructions(ai_related_instructions, human_related_instructions)
    return 0.0 if ai_related_instructions.empty? && human_related_instructions.empty?
    return 0.0 if ai_related_instructions.empty? || human_related_instructions.empty?

    # Normalize titles
    ai_titles = normalize_titles(ai_related_instructions.map { |ri| ri["title"] || "" })
    human_titles = normalize_titles(human_related_instructions.map(&:title))

    # Calculate count similarity
    count_similarity = calculate_count_similarity(ai_related_instructions.length, human_related_instructions.length)

    # Calculate title matching similarity
    title_similarity = calculate_title_similarity(ai_titles, human_titles)

    # Calculate hours similarity
    ai_hours = ai_related_instructions.map { |ri| (ri["hours"] || 0).to_f }.sum
    human_hours = human_related_instructions.sum(&:hours) || 0
    hours_similarity = calculate_hours_similarity(ai_hours, human_hours)

    # Weighted average: 25% count, 50% titles, 25% hours
    score = (
      count_similarity * 0.25 +
      title_similarity * 0.5 +
      hours_similarity * 0.25
    ) * 100

    score.round(2)
  end

  def calculate_count_similarity(ai_count, human_count)
    return 1.0 if ai_count == 0 && human_count == 0
    return 0.0 if ai_count == 0 || human_count == 0

    min_count = [ai_count, human_count].min
    max_count = [ai_count, human_count].max

    min_count.to_f / max_count
  end

  def calculate_title_similarity(ai_titles, human_titles)
    return 1.0 if ai_titles.empty? && human_titles.empty?
    return 0.0 if ai_titles.empty? || human_titles.empty?

    matches = 0
    used_human_indices = []

    ai_titles.each do |ai_title|
      best_match = nil
      best_similarity = 0
      best_index = nil

      human_titles.each_with_index do |human_title, index|
        next if used_human_indices.include?(index)

        similarity = string_similarity(ai_title, human_title)
        if similarity > best_similarity
          best_similarity = similarity
          best_match = human_title
          best_index = index
        end
      end

      # Consider it a match if similarity is above 0.7 (fuzzy matching)
      if best_similarity >= 0.7 && best_index
        matches += 1
        used_human_indices << best_index
      end
    end

    # Calculate average: matches / total unique items
    total_unique = [ai_titles.length, human_titles.length].max
    matches.to_f / total_unique
  end

  def calculate_description_similarity(ai_work_processes, human_work_processes)
    return 0.0 if ai_work_processes.empty? || human_work_processes.empty?

    similarities = []
    ai_work_processes.each do |ai_wp|
      ai_title = normalize(ai_wp["title"] || "")
      best_similarity = 0

      human_work_processes.each do |human_wp|
        if string_similarity(ai_title, normalize(human_wp.title)) >= 0.7
          ai_desc = normalize(ai_wp["description"] || "")
          human_desc = normalize(human_wp.description || "")
          best_similarity = [best_similarity, string_similarity(ai_desc, human_desc)].max
        end
      end

      similarities << best_similarity if best_similarity > 0
    end

    similarities.empty? ? 0.0 : similarities.sum / similarities.length
  end

  def calculate_competencies_similarity(ai_work_processes, human_work_processes)
    return 0.0 if ai_work_processes.empty? || human_work_processes.empty?

    total_similarities = []
    
    ai_work_processes.each do |ai_wp|
      ai_title = normalize(ai_wp["title"] || "")
      matching_human_wp = human_work_processes.find do |human_wp|
        string_similarity(ai_title, normalize(human_wp.title)) >= 0.7
      end

      next unless matching_human_wp

      ai_competencies = (ai_wp["competencies"] || []).map { |c| normalize(c["title"] || "") }
      human_competencies = matching_human_wp.competencies.map { |c| normalize(c.title || "") }

      next if ai_competencies.empty? && human_competencies.empty?

      similarity = calculate_title_similarity(ai_competencies, human_competencies)
      total_similarities << similarity
    end

    total_similarities.empty? ? 0.0 : total_similarities.sum / total_similarities.length
  end

  def calculate_hours_similarity(ai_hours, human_hours)
    return 1.0 if ai_hours == 0 && human_hours == 0
    return 0.0 if ai_hours == 0 || human_hours == 0

    min_hours = [ai_hours, human_hours].min
    max_hours = [ai_hours, human_hours].max

    min_hours.to_f / max_hours
  end

  def calculate_overall_score(work_processes_score, related_instructions_score)
    # Weighted average: 60% work_processes, 40% related_instructions
    ((work_processes_score * 0.6) + (related_instructions_score * 0.4)).round(2)
  end

  def generate_work_processes_details(ai_work_processes, human_work_processes)
    {
      ai_count: ai_work_processes.length,
      human_count: human_work_processes.length,
      ai_titles: ai_work_processes.map { |wp| wp["title"] },
      human_titles: human_work_processes.map(&:title)
    }
  end

  def generate_related_instructions_details(ai_related_instructions, human_related_instructions)
    ai_hours = ai_related_instructions.map { |ri| (ri["hours"] || 0).to_f }.sum
    human_hours = human_related_instructions.sum(&:hours) || 0

    {
      ai_count: ai_related_instructions.length,
      human_count: human_related_instructions.length,
      ai_total_hours: ai_hours,
      human_total_hours: human_hours,
      ai_titles: ai_related_instructions.map { |ri| ri["title"] },
      human_titles: human_related_instructions.map(&:title)
    }
  end

  def normalize_titles(titles)
    titles.map { |title| normalize(title) }.reject(&:empty?)
  end

  def normalize(text)
    return "" if text.blank?
    text.to_s.downcase.strip.gsub(/\s+/, " ")
  end

  def string_similarity(str1, str2)
    return 1.0 if str1 == str2
    return 0.0 if str1.empty? || str2.empty?

    # Simple Levenshtein-like similarity using Jaro-Winkler approximation
    # For a more accurate implementation, you might want to use a gem like 'fuzzy-string-match'
    max_length = [str1.length, str2.length].max
    return 0.0 if max_length == 0

    # Simple approach: count matching character sequences
    matches = 0
    min_length = [str1.length, str2.length].min

    # Check if strings are similar
    if str1.include?(str2) || str2.include?(str1)
      return 0.9 # High similarity for substring matches
    end

    # Calculate character-level similarity
    common_chars = (str1.chars & str2.chars).length
    similarity = (common_chars.to_f / max_length) * 0.7

    # Boost if first characters match
    similarity += 0.2 if str1[0] == str2[0]

    [similarity, 1.0].min
  end
end

