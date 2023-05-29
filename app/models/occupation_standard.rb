class OccupationStandard < ApplicationRecord
  include ActionView::Helpers::NumberHelper
  include Searchable

  belongs_to :occupation, optional: true
  belongs_to :registration_agency, optional: true
  belongs_to :organization, optional: true
  belongs_to :industry, optional: true

  has_many :data_imports
  has_many :related_instructions, -> { order(:sort_order) }, dependent: :destroy
  has_many :wage_steps, -> { order(:sort_order) }, dependent: :destroy
  has_many :work_processes, -> { order(:sort_order).includes(:competencies) }, dependent: :destroy

  has_one_attached :redacted_document

  delegate :title, to: :organization, prefix: true, allow_nil: true
  delegate :title, to: :occupation, prefix: true, allow_nil: true
  delegate :standards_import, to: :source_file, allow_nil: true

  enum ojt_type: [:time, :competency, :hybrid], _suffix: :based
  enum national_standard_type: [:program_standard, :guideline_standard, :occupational_framework], _prefix: :national
  enum status: [:importing, :in_review, :published]

  validates :title, :ojt_type, presence: true
  validates :registration_agency, presence: true, unless: :national?

  MAX_SIMILAR_PROGRAMS_TO_DISPLAY = 5

  settings do
    mappings dynamic: false do
      indexes :title, type: :text
      indexes :ojt_type, type: :text
    end
  end

  after_commit on: [:create] do
    __elasticsearch__.index_document
  end

  scope :by_title, ->(title) do
    if title.present?
      where("title ILIKE ?", "%#{sanitize_sql_like(title).split.join("%")}%")
    end
  end

  scope :by_rapids_code, ->(rapids_code) do
    if rapids_code.present?
      where("rapids_code ILIKE ?", "%#{sanitize_sql_like(rapids_code).split.join("%")}%")
    end
  end

  scope :by_onet_code, ->(onet_code) do
    if onet_code.present?
      where("onet_code ILIKE ?", "%#{sanitize_sql_like(onet_code).split.join("%")}%")
    end
  end

  scope :by_state_id, ->(state_id) do
    if state_id.present?
      joins(:registration_agency).where(registration_agencies: {state_id: state_id})
    end
  end

  scope :by_national_standard_type, ->(standard_types) do
    if standard_types.present?
      types = [standard_types].flatten
      occupational_framework = types.delete("occupational_framework")

      query = where(national_standard_type: types)
      if occupational_framework
        query = query.or(occupational_framework_from_urban_institute)
      end
      query
    end
  end

  scope :occupational_framework_from_urban_institute, -> do
    where(
      national_standard_type: :occupational_framework,
      organization: Organization.urban_institute
    )
  end

  scope :by_ojt_type, ->(ojt_types) do
    if ojt_types.present?
      where(ojt_type: ojt_types)
    end
  end

  class << self
    def industry_count(onet_prefix)
      where("SPLIT_PART(onet_code, '-', 1) = ?", onet_prefix.to_s).count
    end
  end

  def sponsor_name
    organization&.title
  end

  def data_import
    data_imports.last
  end

  def source_file
    data_import.source_file
  end

  def public_document?
    public_document || standards_import.public_document
  end

  def original_file_url
    standards_import.url
  end

  def competencies_count
    if time_based?
      0
    else
      Competency.joins(work_process: :occupation_standard).where(occupation_standards: {id: id}).count
    end
  end

  def rsi_hours
    [rsi_hours_max, rsi_hours_min].compact.first
  end

  def ojt_hours
    [ojt_hours_max, ojt_hours_min].compact.first
  end

  def work_processes_hours
    if competency_based?
      0
    else
      maximum_hours = work_processes.uniq(&:title).pluck(:maximum_hours).compact.sum
      minimum_hours = work_processes.uniq(&:title).pluck(:minimum_hours).compact.sum
      ([maximum_hours, minimum_hours] - [0]).first || 0
    end
  end

  def work_processes_hours_in_human_format
    number_to_human(
      work_processes_hours,
      format: "%n%u",
      precision: 2,
      units:
      {
        thousand: "K"
      }
    )
  end

  def related_instructions_hours
    related_instructions.sum(:hours)
  end

  def related_instructions_hours_in_human_format
    number_to_human(
      related_instructions_hours,
      format: "%n%u",
      precision: 2,
      units:
      {
        thousand: "K"
      }
    )
  end

  def similar_programs
    OccupationStandard.where(
      "title ILIKE ?", "%#{self.class.sanitize_sql_like(title).split.join("%")}%"
    ).where.not(
      id: id
    ).limit(MAX_SIMILAR_PROGRAMS_TO_DISPLAY)
  end

  def ojt_type_display
    ojt_type&.titleize
  end

  def show_national_occupational_framework_badge?
    national_occupational_framework? &&
      organization_id.present? &&
      organization_id == Organization.urban_institute&.id
  end

  private

  def national?
    national_standard_type.present?
  end
end
