class OccupationStandard < ApplicationRecord
  belongs_to :occupation, optional: true
  belongs_to :registration_agency, optional: true
  belongs_to :organization, optional: true
  has_many :data_imports

  has_many :related_instructions, dependent: :destroy
  has_many :wage_steps, dependent: :destroy
  has_many :work_processes, -> { includes(:competencies) }, dependent: :destroy

  delegate :title, to: :organization, prefix: true, allow_nil: true
  delegate :title, to: :occupation, prefix: true, allow_nil: true
  delegate :standards_import, to: :source_file, allow_nil: true

  enum ojt_type: [:time, :competency, :hybrid], _suffix: :based
  enum national_standard_type: [:program_standard, :guideline_standard, :occupational_framework], _prefix: :national
  enum status: [:importing, :in_review, :published]

  validates :title, presence: true
  validates :registration_agency, presence: true, unless: :national?

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
    standards_import.public_document
  end

  def original_file_url
    standards_import.url
  end

  def competencies_count
    Competency.joins(work_process: :occupation_standard).where(occupation_standards: {id: id}).count
  end

  def rsi_hours
    [rsi_hours_max, rsi_hours_min].compact.first
  end

  def ojt_hours
    [ojt_hours_max, ojt_hours_min].compact.first
  end

  def work_processes_hours
    maximum_hours = work_processes.sum(:maximum_hours)
    minimum_hours = work_processes.sum(:minimum_hours)
    ([maximum_hours, minimum_hours] - [0]).first
  end

  def related_instructions_hours
    related_instructions.sum(:hours)
  end

  def similar_programs
    OccupationStandard.where("title ILIKE ?", "%#{self.class.sanitize_sql_like(title).split.join("%")}%") - [self]
  end

  private

  def national?
    national_standard_type.present?
  end
end
