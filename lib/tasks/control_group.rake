namespace :control_group do
  desc "Select 500 occupation standards as control group using stratified random sampling"
  task select: :environment do
    puts "Selecting 500 control group standards..."
    
    # First, clear any existing control group flags
    OccupationStandard.where(control_group: true).update_all(control_group: false)
    puts "Cleared existing control group flags"
    
    # Select standards that have been converted by humans (have data_imports)
    # We assume human-converted standards have data_imports
    human_standards = OccupationStandard
      .joins(:data_imports)
      .where.not(id: OccupationStandard.joins(:open_ai_import).select(:id))
      .distinct
    
    puts "Found #{human_standards.count} human-converted standards"
    
    # Define target distribution
    total_needed = 500
    oa_needed = (total_needed * 2.0 / 3.0).round # ~333
    saa_needed = total_needed - oa_needed # ~167
    
    # Get counts for each ojt_type for OA and SAA separately
    ojt_types = [:time, :competency, :hybrid]
    
    # Calculate proportions needed for each combination
    # We'll try to get roughly equal proportions of each ojt_type within OA and SAA
    selected = []
    
    # Select OA standards (2/3 of total)
    oa_standards = human_standards
      .joins(registration_agency: :state)
      .joins(:registration_agency)
      .where(registration_agencies: { agency_type: :oa })
    
    puts "Found #{oa_standards.count} OA standards"
    
    oa_ojt_counts = ojt_types.map do |ojt_type|
      [ojt_type, oa_standards.where(ojt_type: ojt_type).count]
    end.to_h
    
    oa_per_ojt_type = oa_needed / 3.0 # ~111 per ojt_type for OA
    
    ojt_types.each do |ojt_type|
      available = oa_standards.where(ojt_type: ojt_type).order("RANDOM()")
      needed = [oa_per_ojt_type.round, available.count].min
      
      if needed > 0
        selected_standards = available.limit(needed).to_a
        selected.concat(selected_standards)
        puts "Selected #{selected_standards.count} OA #{ojt_type} standards"
      end
    end
    
    # Select SAA standards (1/3 of total)
    saa_standards = human_standards
      .joins(registration_agency: :state)
      .joins(:registration_agency)
      .where(registration_agencies: { agency_type: :saa })
    
    puts "Found #{saa_standards.count} SAA standards"
    
    saa_ojt_counts = ojt_types.map do |ojt_type|
      [ojt_type, saa_standards.where(ojt_type: ojt_type).count]
    end.to_h
    
    saa_per_ojt_type = saa_needed / 3.0 # ~56 per ojt_type for SAA
    
    ojt_types.each do |ojt_type|
      available = saa_standards.where(ojt_type: ojt_type).order("RANDOM()")
      needed = [saa_per_ojt_type.round, available.count].min
      
      if needed > 0
        selected_standards = available.limit(needed).to_a
        selected.concat(selected_standards)
        puts "Selected #{selected_standards.count} SAA #{ojt_type} standards"
      end
    end
    
    # If we don't have exactly 500, fill remaining slots randomly
    current_count = selected.length
    if current_count < total_needed
      remaining_needed = total_needed - current_count
      selected_ids = selected.map(&:id)
      
      remaining = human_standards
        .where.not(id: selected_ids)
        .order("RANDOM()")
        .limit(remaining_needed)
        .to_a
      
      selected.concat(remaining)
      puts "Selected #{remaining.count} additional standards to reach 500"
    elsif current_count > total_needed
      # If we have more than 500, randomly reduce
      selected = selected.shuffle.first(total_needed)
      puts "Randomly reduced to exactly 500 standards"
    end
    
    # Mark selected standards as control group
    selected_ids = selected.map(&:id)
    OccupationStandard.where(id: selected_ids).update_all(control_group: true)
    
    # Print summary
    final_count = OccupationStandard.where(control_group: true).count
    puts "\n=== Control Group Selection Complete ==="
    puts "Total selected: #{final_count}"
    
    # Breakdown by agency type
    oa_count = OccupationStandard.where(control_group: true)
      .joins(:registration_agency)
      .where(registration_agencies: { agency_type: :oa })
      .count
    saa_count = OccupationStandard.where(control_group: true)
      .joins(:registration_agency)
      .where(registration_agencies: { agency_type: :saa })
      .count
    
    puts "OA: #{oa_count} (#{(oa_count.to_f / final_count * 100).round(1)}%)"
    puts "SAA: #{saa_count} (#{(saa_count.to_f / final_count * 100).round(1)}%)"
    
    # Breakdown by OJT type
    ojt_types.each do |ojt_type|
      count = OccupationStandard.where(control_group: true, ojt_type: ojt_type).count
      puts "#{ojt_type.to_s.capitalize}: #{count} (#{(count.to_f / final_count * 100).round(1)}%)"
    end
    
    puts "=========================================="
  end
end

