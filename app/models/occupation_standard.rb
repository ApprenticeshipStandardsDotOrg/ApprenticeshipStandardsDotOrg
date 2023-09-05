class OccupationStandard < ApplicationRecord
  include ActionView::Helpers::NumberHelper
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  belongs_to :occupation, optional: true
  belongs_to :registration_agency
  belongs_to :organization, optional: true
  belongs_to :industry, optional: true

  has_many :data_imports
  has_many :related_instructions, -> { order(:sort_order) }, dependent: :destroy
  has_many :wage_steps, -> { order(:sort_order) }, dependent: :destroy
  has_many :work_processes, -> { order(:sort_order).includes(:competencies) }, dependent: :destroy

  has_one_attached :redacted_document

  delegate :title, to: :organization, prefix: true, allow_nil: true
  delegate :title, to: :occupation, prefix: true, allow_nil: true
  delegate :name, to: :industry, prefix: true, allow_nil: true
  delegate :standards_import, to: :source_file, allow_nil: true
  delegate :state, to: :registration_agency, allow_nil: true

  enum ojt_type: [:time, :competency, :hybrid], _suffix: :based
  enum national_standard_type: [:program_standard, :guideline_standard, :occupational_framework], _prefix: :national
  enum status: [:importing, :in_review, :published]

  validates :title, :ojt_type, presence: true
  validates :registration_agency, presence: true

  MAX_SIMILAR_PROGRAMS_TO_DISPLAY = 5

  index_name "occupation_standards_#{Rails.env}"
  number_of_shards = Rails.env.production? ? 2 : 1
  es_settings = {
    index: {
      max_ngram_diff: 20,
      number_of_shards: number_of_shards,
      analysis: {
        filter: {
          english_stop: {
            type: "stop",
            stopwords: "_english_"
          },
          ngram_filter: {
            type: "ngram",
            min_gram: 3,
            max_gram: 20
          }
        },
        tokenizer: {
          autocomplete_tokenizer: {
            type: "edge_ngram",
            min_gram: 2,
            max_gram: 20,
            token_chars: ["letter", "digit", "punctuation"]
          }
        },
        char_filter: {
          my_char_filter: {
            type: "mapping",
            mappings: [
              ", =>",
              ". =>",
              "- =>"
            ]
          }
        },
        analyzer: {
          english_stop_with_ngrams: {
            tokenizer: "standard",
            filter: [
              "lowercase",
              "english_stop",
              "ngram_filter"
            ]
          },
          autocomplete: {
            tokenizer: "autocomplete_tokenizer",
            filter: ["lowercase"],
            char_filter: ["my_char_filter"]
          }
        }
      }
    }
  }

  settings(es_settings) do
    mappings dynamic: false do
      indexes :industry_name, type: :text, analyzer: :english
      indexes :national_standard_type, type: :text, analyzer: :keyword
      indexes :ojt_type, type: :text, analyzer: :keyword
      indexes :onet_code, type: :text, analyzer: :autocomplete
      indexes :rapids_code, type: :text, analyzer: :autocomplete
      indexes :state, type: :text, analyzer: :keyword
      indexes :state_id, type: :keyword
      indexes :title, type: :text, analyzer: :english
      indexes :title_typeahead, type: :text, analyzer: :english_stop_with_ngrams
      indexes :work_process_titles, type: :text, analyzer: :english
      indexes :related_job_titles, type: :text, analyzer: :english
      indexes :created_at, type: :date
    end
  end

  def as_indexed_json(_ = {})
    as_json(
      only: [:title, :ojt_type, :onet_code, :rapids_code, :national_standard_type, :created_at]
    ).merge(
      industry_name: industry_name,
      national_standard_type: national_standard_type_with_adjustment,
      state: state_abbreviation,
      state_id: state_id,
      title_typeahead: title,
      work_process_titles: work_processes.pluck(:title).uniq,
      related_job_titles: related_job_titles
    )
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

  scope :by_state_abbreviation, ->(state_abbreviation) do
    if state_abbreviation.present?
      joins(registration_agency: :state).where(
        registration_agencies: {
          states: {
            abbreviation: state_abbreviation.upcase
          }
        }
      )
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

  scope :by_industry_name, ->(name) do
    if name.present?
      ids = joins(:industry).where("industries.name ILIKE ?", "%#{sanitize_sql_like(name).split.join("%")}%").pluck(:id)
      where(id: ids)
    end
  end

  scope :with_work_processes, -> { joins(:work_processes).distinct }

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

  def national_standard_type_with_adjustment
    case national_standard_type
    when "occupational_framework"
      (organization == Organization.urban_institute) ? "occupational_framework" : nil
    else
      national_standard_type
    end
  end

  def related_job_titles
    onet = Onet.find_by(code: onet_code)
    onet&.related_job_titles || []
  end

  def source_file
    data_import.source_file
  end

  def public_document?
    source_file.public_document || standards_import.public_document
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
    if Flipper.enabled?(:similar_programs_elasticsearch)
      SimilarOccupationStandards.similar_to(self)
    else
      similar_programs_deprecated
    end
  end

  def ojt_type_display
    ojt_type&.titleize
  end

  def show_national_occupational_framework_badge?
    national_occupational_framework? &&
      organization_id.present? &&
      organization_id == Organization.urban_institute&.id
  end

  def display_for_typeahead
    title.strip
  end

  def hours_meet_occupation_requirements?
    return true if occupation.blank?
    oa_hours = occupation.time_based_hours.to_i

    work_processes_hours >= oa_hours
  end

  def state_abbreviation
    state&.abbreviation
  end

  def state_id
    state&.id
  end

  private

  def national?
    national_standard_type.present?
  end

  def similar_programs_deprecated
    OccupationStandard.where(
      "title ILIKE ?", "%#{self.class.sanitize_sql_like(title).split.join("%")}%"
    ).where.not(
      id: id
    ).limit(MAX_SIMILAR_PROGRAMS_TO_DISPLAY)
  end
end
