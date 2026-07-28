class OpenAIPrompt < ApplicationRecord
  DEFAULT_NAME = "Default OpenAI Prompt"
  DEFAULT_PROMPT = "Get the Occupation standard info from the following text in JSON format. JSON output needs the following fields:\
      title: Title of the Occupation standard.
      existingTitle: An existing or alternative title for the occupation.
      onetCode: Also can be found as O*NET code.
      rapidsCode: RAPIDS code for the occupation.
      organization: The name of the organization.
      registrationAgency: The name of the agency of the state.
      state: The two-letter US state abbreviation associated with the standard. Extract this from any available document context including registration agency name, state apprenticeship agency name, state department name, state seal/header/footer, sponsor address, county/city references, document title, source URL, or other geographic clues. If only a county, city, or state agency is present, infer the state from that context. If this is a national, federal, Office of Apprenticeship, or generic RAPIDS standard and no specific state applies, return null.
      registrationAgencyType: Must be one of \"oa\" or \"saa\". Use \"oa\" for Office of Apprenticeship, national programs, federal standards, or generic RAPIDS standards without a state. Use \"saa\" for State Apprenticeship Agency programs. If value not found, return null.
      registrationState: The two-letter US state abbreviation for the registration agency. For state-level standards, this should match state. If the document only implies a state through county, city, agency, address, or other context, infer and return the two-letter abbreviation. If this is a national program, return null.
      nationalStandardType: If this is a national standard, return one of \"program_standard\", \"guideline_standard\", or \"occupational_framework\". If this is not a national standard, return null.
      ojtType: On the job type or apprenticeship approach. It must be one of the following values:
      \"time\", \"competency\", or \"hybrid\". Transform if needed to match any of those three values. An
      example of an expected transformation is from \"Competency-based\" to \"competency\".
      registrationDate: The registration date of the occupation.
      workProcesses: an array of work processes. Each work process has the following fields:
      title: title of the work process.
      description: description of the work process. If value not found, return null.
      defaultHours: amount of hours. It is optional. If value not found, return null.
      minimumHours: the minimum amount of hours required. If value not found, return null.
      maximumHours: the maximum amount of hours required. If value not found, return null.
      competencies: It is an array of text with each competency representing a line.
      Each competency has the following fields:
      title: title of the competency.
      End of workProcesses info.
      relatedInstructions: A new array of related instructions. Related instructions are not part of competencies or work processes. Each related instruction has the following fields:
      title: Title of the related instruction.
      description: Description of the related instruction. If value not found, return null.
      code: Code for the related instruction. If value not found, return null.
      hours: Hours dedicated to the related instruction. If value not found, return null.
      organization: Organization in charge of the related instruction. If value not found, return null.
      End of relatedInstructions info.
      extractionWarnings: An array of strings describing fields that could not be confidently extracted or context used for inferred values such as registrationState.

      Return only the output in JSON format without any block, code or markdown.

      The input text is:\n\n
  "

  before_save :clear_existing_default, if: :default?

  validates :name, :prompt, presence: true

  class << self
    def default
      find_by!(default: true)
    end

    def create_default!(name: DEFAULT_NAME, prompt: DEFAULT_PROMPT)
      transaction do
        where(default: true).update_all(default: false, updated_at: Time.current)
        create!(name: name, prompt: prompt, default: true)
      end
    end
  end

  private

  def clear_existing_default
    self.class
      .where(default: true)
      .where.not(id: id)
      .update_all(default: false, updated_at: Time.current)
  end
end
