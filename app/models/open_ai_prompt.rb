class OpenAIPrompt < ApplicationRecord
  DEFAULT_NAME = "Default OpenAI Prompt"
  DEFAULT_PROMPT = <<~PROMPT
    Extract registered apprenticeship occupation standard data from the following PDF text.
    Return only valid JSON. Do not include markdown, prose, code fences, or comments.

    Preserve the document's structure. Do not summarize or collapse tables, numbered lists, bullets, skills, tasks, or courses into paragraph descriptions.
    If a section exists but labels are imperfect because of PDF text extraction, extract the best-supported values and add a short extractionWarnings entry.

    JSON fields:
    title: Title of the occupation standard.
    existingTitle: An existing or alternative title for the occupation.
    onetCode: Also can be found as O*NET code.
    rapidsCode: RAPIDS code for the occupation. Preserve alphabetic suffixes such as 2028CB.
    organization: The sponsor or organization name.
    registrationAgency: The registration agency name.
    state: The two-letter US state abbreviation associated with the standard. Extract this from registration agency name, state apprenticeship agency name, state department name, state seal/header/footer, sponsor address, county/city references, document title, source URL, or other geographic clues. If only a county, city, or state agency is present, infer the state from that context. If this is a national, federal, Office of Apprenticeship, or generic RAPIDS standard and no specific state applies, return null.
    registrationAgencyType: Must be one of "oa" or "saa". Use "oa" for Office of Apprenticeship, national programs, federal standards, or generic RAPIDS standards without a state. Use "saa" for State Apprenticeship Agency programs. If value not found, return null.
    registrationState: The two-letter US state abbreviation for the registration agency. For state-level standards, this should match state. If the document only implies a state through county, city, agency, address, or other context, infer and return the two-letter abbreviation. If this is a national program, return null.
    nationalStandardType: If this is a national standard, return one of "program_standard", "guideline_standard", or "occupational_framework". If this is not a national standard, return null.
    ojtType: On-the-job type or apprenticeship approach. Must be one of "time", "competency", or "hybrid". Transform values like "Competency-based" to "competency".
    registrationDate: The registration date of the occupation.

    workProcesses: An array of work process objects. Look for sections or tables named Work Process Schedule, Work Processes, Schedule of Work Experience, On-the-Job Learning, On-the-Job Training, OJL, OJT, Appendix A, Major Processes, Work Experience, or similar.
    Each work process object has:
    title: The work process, duty, task group, or work activity title.
    description: Description of the work process. If not found, return null.
    defaultHours: Hours only when the document gives one unlabeled or default hour value. Remove commas. If not found, return null.
    minimumHours: Minimum hours when a range or minimum column is present. Remove commas. If not found, return null.
    maximumHours: Maximum hours when a range, maximum column, or single required hour value is present. Remove commas. If not found, return null.
    competencies: An array of competency objects. Look for skills, tasks, duties, steps, performance objectives, apprentice will be able to items, or bullet lines under a work process. Each competency represents one line item and has:
    title: The competency, skill, task, duty, or performance objective text.

    relatedInstructions: An array of related instruction objects. Related instructions are not competencies or work processes. Look for sections or tables named Related Instruction, Related Technical Instruction, RTI, RSI, Classroom Instruction, Appendix B, Courses, or similar.
    Each related instruction object has:
    title: Title of the course or related instruction.
    description: Description. If not found, return null.
    code: Course or instruction code. If not found, return null.
    hours: Hours dedicated to the related instruction. Remove commas. If not found, return null.
    organization: Organization in charge of the related instruction. If not found, return null.

    extractionWarnings: An array of strings describing fields that could not be confidently extracted or context used for inferred values such as registrationState.

    The input text is:

  PROMPT

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
