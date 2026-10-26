class OpenAIPrompt < ApplicationRecord
  DEFAULT_NAME = "Default OpenAI Prompt"
  DEFAULT_PROMPT = <<~PROMPT
    Extract registered apprenticeship occupation standard data from the following PDF text.
    Return only valid JSON. Do not include markdown, prose, code fences, or comments.

    Preserve the document's structure. Do not summarize or collapse tables, numbered lists, bullets, skills, tasks, or courses into paragraph descriptions.
    If a section exists but labels are imperfect because of PDF text extraction, extract the best-supported values and add a short extractionWarnings entry.
    For Office of Apprenticeship state standards, Appendix A is the primary source of truth for the occupation, work process schedule, OJT approach, work process hours, competencies, and related instruction outline. Prefer Appendix A over boilerplate program language elsewhere in the document.
    First identify every distinct occupation standard or occupation-specific appendix in the document, for OA and SAA documents alike. Repeated references, alternate titles, boilerplate examples, and continuation pages do not create additional occupations.
    A changed footer/running header, reference occupation title, or course name alone is not evidence of another occupation. Require an independently headed occupation standard/work-process schedule, or a separate occupational objective with its own attributable schedule. Continuation pages can retain stale occupation names from an older template: keep those rows with the opening occupation when the schedule continues, and explain the inconsistent footer in extractionWarnings rather than inventing a second occupation or dropping its continuation rows.
    Return a document object with documentOccupationCount, singleOccupation, occupationInventory, extractionWarnings, and occupations. occupations is an array of complete occupation objects, including for a single-occupation PDF. Extract EVERY occupation, not just the first, dominant, or selected one. Never merge processes, competencies, or courses from different occupations.
    Each occupations object must contain its own title, existingTitle, onetCode, rapidsCode, ojtType, organization, registrationAgencyType, registrationState, nationalStandardType, registrationDate, appendixLabel, pageNumbers, workProcesses, relatedInstructions, and extractionWarnings. The occupation field definitions below apply separately to every object in occupations, not to the document root. Repeat shared program/registration context only when it applies to that occupation. Keep occupation-specific overrides.

    JSON fields:
    documentOccupationCount: Number of distinct occupations or Appendix A occupation sections found in the PDF. Return 1 only when the document clearly contains one occupation.
    singleOccupation: true when the PDF clearly contains exactly one occupation standard; false when multiple occupations are present or the count is ambiguous.
    occupationInventory: An array of occupation objects found in the PDF. Each object has title, existingTitle, onetCode, rapidsCode, ojtType, appendixLabel, and pageNumbers when found.
    occupations: One complete occupation object per inventory entry, in document order. Its identifying fields must match that inventory entry. Include separate workProcesses and relatedInstructions arrays for EACH occupation. Do not return inventory-only results for multi-occupation documents.
    title: Title of the occupation standard.
    existingTitle: An existing or alternative title for the occupation.
    onetCode: Also can be found as O*NET code.
    rapidsCode: The occupation's RAPIDS or RAIS occupation code. Older standards may label the same occupation identifier SYMBOL in a header table alongside SIC, SOC, SUFFIX, and Term; extract that SYMBOL value, not SIC or SOC. Preserve any alphabetic suffix actually printed as part of the occupation code; do not append an administrative numeric SUFFIX such as 000. If the document does not provide a RAPIDS, RAIS, or occupation SYMBOL code, return null. Never infer a RAPIDS code from an occupation title or substitute a state program number, WSATC number, MA# sponsor/registration identifier, course number, year, O*NET code, or a code from instructions/examples.
    organization: The sponsor or organization name.
    registrationAgency: The registration agency name.
    state: The two-letter US state abbreviation associated with the standard. Extract this from registration agency name, state apprenticeship agency name, state department name, state seal/header/footer, sponsor address, county/city references, document title, source URL, or other geographic clues. If only a county, city, or state agency is present, infer the state from that context. If this is a national, federal, Office of Apprenticeship, or generic RAPIDS standard and no specific state applies, return null.
    registrationAgencyType: Must be one of "oa" or "saa". Use "oa" for Office of Apprenticeship, national programs, federal standards, or generic RAPIDS standards without a state. Use "saa" for State Apprenticeship Agency programs. If value not found, return null.
    registrationState: The two-letter US state abbreviation for the registration agency. For state-level standards, this should match state. If the document only implies a state through county, city, agency, address, or other context, infer and return the two-letter abbreviation. If this is a national program, return null.
    nationalStandardType: If this is a national standard, return one of "program_standard", "guideline_standard", or "occupational_framework". If this is not a national standard, return null.
    ojtType: On-the-job type or apprenticeship approach. Must be one of "time", "competency", or "hybrid". Transform values like "Competency-based" to "competency".
    registrationDate: The registration date of the occupation.

    workProcesses: An array of work process objects. Look for sections or tables named Work Process Schedule, Work Processes, Schedule of Work Experience, On-the-Job Learning, On-the-Job Training, OJL, OJT, Appendix A, Major Processes, Work Experience, or similar.
    Extract the work process schedule belonging to this occupation's appendix or section, including continuation pages. If the document contains several occupations, produce a separate complete occupation object for each. Use appendix labels, titles, codes, and page boundaries to associate each schedule with its occupation. Never empty all schedules just because the document contains multiple occupations. If a particular occupation's schedule is absent or unreadable, report that in its extractionWarnings and keep its arrays empty rather than borrowing another occupation's rows.
    Work process names must come from the row labels/headings in the schedule. Keep one workProcesses item per schedule row or heading; do not merge adjacent rows.
    Work process titles are the primary row labels in Appendix A. Do not promote competency/task bullets into separate work process titles unless the document presents them as work process rows.
    For time-based and hybrid standards, preserve row-level OJT hours exactly as shown. For a single required hours column, put the value in maximumHours. For min/max columns, put values in minimumHours and maximumHours. For competency-based standards, do not invent hours when the Appendix A table has no hours.
    Do not treat wage schedules, apprentice ratios, selection procedures, probationary periods, signatures, or boilerplate terms as work processes.
    Each work process object has:
    title: The work process, duty, task group, or work activity title.
    description: Description of the work process. If not found, return null.
    defaultHours: Hours only when the document gives one unlabeled or default hour value. Remove commas. If not found, return null.
    minimumHours: Minimum hours when a range or minimum column is present. Remove commas. If not found, return null.
    maximumHours: Maximum hours when a range, maximum column, or single required hour value is present. Remove commas. If not found, return null.
    competencies: An array of competency objects. Look for skills, tasks, duties, steps, performance objectives, apprentice will be able to items, or bullet lines under a work process. Each competency represents one line item and has:
    title: The competency, skill, task, duty, or performance objective text.
    Do not put competency names only in the work process description. They must appear as individual competencies.
    Only create nested competencies when the source actually lists separate skills/tasks beneath a process or group. A flat competency table has one workProcesses item per row with competencies: []. Never copy a row's title into both the work process title and a duplicate child competency, and never invent a nested hierarchy.
    Do not put related instruction course titles in competencies.

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
