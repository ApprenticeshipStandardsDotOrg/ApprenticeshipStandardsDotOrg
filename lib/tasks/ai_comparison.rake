namespace :ai_comparison do
  desc "Compare AI imports to human data_imports for control group standards"
  task run: :environment do
    puts "Running AI comparison for control group standards..."
    
    control_group_standards = OccupationStandard
      .control_group
      .includes(:open_ai_import, :work_processes, :related_instructions, work_processes: :competencies)
    
    total = control_group_standards.count
    puts "Found #{total} control group standards"
    
    compared = 0
    skipped = 0
    errors = 0
    
    control_group_standards.find_each.with_index do |standard, index|
      print "\rProcessing #{index + 1}/#{total}..."
      
      if standard.open_ai_import.blank?
        skipped += 1
        next
      end
      
      begin
        result = CompareAiToHuman.new(standard).call
        if result
          compared += 1
        else
          skipped += 1
        end
      rescue => e
        errors += 1
        puts "\nError processing standard #{standard.id}: #{e.message}"
      end
    end
    
    puts "\n\n=== AI Comparison Complete ==="
    puts "Total control group standards: #{total}"
    puts "Compared: #{compared}"
    puts "Skipped (no AI import): #{skipped}"
    puts "Errors: #{errors}"
    
    # Print summary statistics
    results = AIComparisonResult.all
    if results.any?
      avg_score = results.average(:overall_score) || 0
      low_scores = results.low_score(70).count
      flagged = results.flagged.count
      
      puts "\n=== Comparison Statistics ==="
      puts "Average overall score: #{avg_score.round(2)}"
      puts "Low scores (< 70): #{low_scores}"
      puts "Flagged for review: #{flagged}"
      puts "==============================="
    end
  end

  desc "Flag low-scoring comparisons for review"
  task flag_low_scores: :environment do
    puts "Flagging low-scoring comparisons..."
    
    threshold = ENV.fetch("THRESHOLD", "70").to_f
    
    results = AIComparisonResult.where("overall_score < ?", threshold)
    count = results.count
    
    results.update_all(flagged_by_system: true, needs_review: true)
    
    puts "Flagged #{count} comparisons with scores below #{threshold}"
  end
end

