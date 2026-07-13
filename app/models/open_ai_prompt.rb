class OpenAIPrompt < ApplicationRecord
  DEFAULT_NAME = "Default OpenAI Prompt"
  DEFAULT_PROMPT = "Get the Occupation standard info from the following text in JSON format. JSON output needs the following fields:\
      title: Title of the Occupation standard.
      existingTitle: An existing or alternative title for the occupation.
      onetCode: Also can be found as O*NET code.
      rapidsCode: RAPIDS code for the occupation.
      organization: The name of the organization.
      registrationAgency: The name of the agency of the state.
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
