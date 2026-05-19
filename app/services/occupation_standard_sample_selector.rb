require "zlib"

class OccupationStandardSampleSelector
  DEFAULT_SAMPLE_SIZE = 500
  FEDERAL_SHARE = 0.6
  STATE_ABBREVIATIONS = %w[CA OR WA NC].freeze

  Result = Struct.new(:selected_ids, :manual_ids, :dry_run, keyword_init: true) do
    def selected_count
      selected_ids.count
    end
  end

  def initialize(
    sample_size: ENV.fetch("SAMPLE_SIZE", DEFAULT_SAMPLE_SIZE).to_i,
    manual_ids: ENV.fetch("MANUAL_OCCUPATION_STANDARD_IDS", "").split(",").map(&:strip).compact_blank,
    seed: ENV.fetch("SAMPLE_SEED", Time.zone.today.to_s),
    dry_run: ActiveModel::Type::Boolean.new.cast(ENV.fetch("DRY_RUN", false))
  )
    @sample_size = sample_size
    @manual_ids = manual_ids
    @random = Random.new(Zlib.crc32(seed.to_s))
    @dry_run = dry_run
  end

  def call
    selected_ids = manual_conversion_ids
    remaining = @sample_size - selected_ids.count

    federal_target = [federal_quota - selected_ids_in_scope(selected_ids, federal_scope), remaining].min
    selected_ids += balanced_sample(federal_scope, federal_target, selected_ids)
    remaining = @sample_size - selected_ids.count

    state_quota_by_abbreviation.each do |abbreviation, quota|
      break if remaining <= 0

      scope = state_scope(abbreviation)
      state_target = [quota - selected_ids_in_scope(selected_ids, scope), remaining].min
      selected_ids += balanced_sample(scope, state_target, selected_ids)
      remaining = @sample_size - selected_ids.count
    end

    selected_ids += balanced_sample(eligible_scope, @sample_size - selected_ids.count, selected_ids)
    selected_ids = selected_ids.uniq

    persist(selected_ids) unless @dry_run

    Result.new(selected_ids: selected_ids, manual_ids: manual_conversion_ids, dry_run: @dry_run)
  end

  private

  def eligible_scope
    OccupationStandard.with_work_processes
  end

  def federal_scope
    eligible_scope.where.not(rapids_code: [nil, ""])
  end

  def state_scope(abbreviation)
    eligible_scope.by_state_abbreviation(abbreviation)
  end

  def manual_conversion_ids
    @manual_conversion_ids ||= (manual_conversion_data_import_scope.pluck(:occupation_standard_id) + explicit_manual_ids).uniq
  end

  def explicit_manual_ids
    eligible_scope.where(id: @manual_ids).ids
  end

  def manual_conversion_data_import_scope
    DataImport
      .joins(:import)
      .joins("INNER JOIN standards_imports ON standards_imports.id = imports.parent_id")
      .where(imports: {parent_type: "StandardsImport"})
      .where.not(standards_imports: {courtesy_notification: StandardsImport.courtesy_notifications[:not_required]})
      .where(occupation_standard_id: eligible_scope.select(:id))
  end

  def federal_quota
    (@sample_size * FEDERAL_SHARE).round
  end

  def state_quota
    @sample_size - federal_quota
  end

  def state_quota_by_abbreviation
    base_quota, remainder = state_quota.divmod(STATE_ABBREVIATIONS.count)

    STATE_ABBREVIATIONS.each_with_index.to_h do |abbreviation, index|
      [abbreviation, base_quota + ((index < remainder) ? 1 : 0)]
    end
  end

  def selected_ids_in_scope(selected_ids, scope)
    return 0 if selected_ids.empty?

    scope.where(id: selected_ids).count
  end

  def balanced_sample(scope, quota, excluded_ids)
    return [] if quota <= 0

    selected_ids = []
    base_quota, remainder = quota.divmod(OccupationStandard.ojt_types.count)

    OccupationStandard.ojt_types.keys.each_with_index do |ojt_type, index|
      ojt_quota = base_quota + ((index < remainder) ? 1 : 0)
      selected_ids += random_ids(scope.where(ojt_type: ojt_type), ojt_quota, excluded_ids + selected_ids)
    end

    selected_ids += random_ids(scope, quota - selected_ids.count, excluded_ids + selected_ids)
    selected_ids
  end

  def random_ids(scope, count, excluded_ids)
    return [] if count <= 0

    scope.where.not(id: excluded_ids).pluck(:id).shuffle(random: @random).first(count)
  end

  def persist(selected_ids)
    OccupationStandard.transaction do
      OccupationStandard.where(sample: true).update_all(sample: false)
      OccupationStandard.where(id: selected_ids).update_all(sample: true)
    end
  end
end
