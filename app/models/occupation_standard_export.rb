class OccupationStandardExport
  DOCX_TEMPLATE_PATH = Rails.root.join("app", "documents", "templates", "occupation_standards_time_approach_template.docx")

  attr_reader :occupation_standard

  def initialize(occupation_standard)
    @occupation_standard = occupation_standard
  end

  def call
    template = Sablon.template(File.expand_path(DOCX_TEMPLATE_PATH))
    template.render_to_string(context_hash)
  end

  def filename
    title = occupation_standard.title.parameterize
    "#{title}-#{Time.zone.now.iso8601}.docx"
  end

  private

  def context_hash
    {
      occupation_standard: occupation_standard,
      ojt_type: occupation_standard.ojt_type&.titleize
    }
  end
end
