class ImportOccupationStandardRelatedInstruction
  def initialize(occupation_standard:, data_import:)
    @occupation_standard = occupation_standard
    @data_import = data_import
    @row = nil
  end

  def call
    remove_existing_related_instructions

    data_import.file.open do |file|
      xlsx = Roo::Spreadsheet.open(file, extension: :xlsx)
      sheet = xlsx.sheet(2)

      sheet.parse(headers: true).each_with_index do |row, index|
        next if index.zero?
        organization = nil

        if row["Related Training Organization"]
          organization = Organization.find_or_create_by!(
            title: row["Related Training Organization"]
          )
        end

        related_instruction = RelatedInstruction.where(
          occupation_standard: occupation_standard,
          organization: organization,
          code: row["Course Code"],
          title: row["Course Name"],
          sort_order: row["Course Sort Order"]
        ).first_or_initialize
        related_instruction.description = row["Course Description"]
        related_instruction.hours = row["Course Hours"]
        related_instruction.save!
      end
    end
  end

  private

  attr_reader :occupation_standard, :data_import, :row

  def remove_existing_related_instructions
    if occupation_standard.persisted?
      occupation_standard.related_instructions.destroy_all
    end
  end
end
