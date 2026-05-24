namespace :occupation_standards do
  desc "Select the occupation standards sample set"
  task select_sample: :environment do
    result = OccupationStandardSampleSelector.new.call
    scope = OccupationStandard.where(id: result.selected_ids)
    ojt_type_counts = scope.group(:ojt_type).count.transform_keys do |key|
      key.is_a?(Integer) ? OccupationStandard.ojt_types.key(key) : key
    end

    puts "Selected #{result.selected_count} occupation standards for the sample"
    puts "Dry run: #{result.dry_run}"
    puts "Manual conversions included: #{result.manual_ids.count}"
    puts "RAPIDS records: #{scope.where.not(rapids_code: [nil, ""]).count}"
    puts "OJT type counts: #{ojt_type_counts}"

    OccupationStandardSampleSelector::STATE_ABBREVIATIONS.each do |abbreviation|
      puts "#{abbreviation} records: #{scope.by_state_abbreviation(abbreviation).count}"
    end
  end
end
