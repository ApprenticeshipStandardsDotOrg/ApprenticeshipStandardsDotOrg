class ImportOccupationStandardRelatedInstruction
  attr_reader :occupation_standard, :data_import, :row

  def initialize(occupation_standard:, data_import:)
    @occupation_standard = occupation_standard
    @data_import = data_import
    @row = nil
  end

  def call
    related_instructions = []
    data_import.file.open do |file|
      xlsx = Roo::Spreadsheet.open(file, extension: :xlsx)
      sheet = xlsx.sheet(2)

      sheet.parse(headers: true).each_with_index do |row, index|
        next if index.zero?

        organization = Organization.find_or_create_by!(
          title: row["Related Training Organization"]
        )

        course = Course.where(
          title: row["Course Name"],
          code: row["Course Code"],
          organization: organization
        ).first_or_create!(
          description: row["Course Description"],
          hours: row["Course Hours"]
          
        )

        related_instruction = RelatedInstruction.where(
          occupation_standard: occupation_standard,
          sort_order: row["Course Sort Order"]
        ).first_or_initialize(
          course: course
        )
        related_instructions << related_instruction
      end
    end

    related_instructions
  end

  private

end
