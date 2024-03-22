module ImportViaChatgpt
  class ProcessDataImport
    def initialize(attachment:)
      @attachment = attachment
      @text = PdfFile.text(attachment)
    end

    # TODO: collect occupation_standard from document
    def work_processes(occupation_standard)
      @work_processes ||= import_work_processes(occupation_standard)
    end

    private

    attr_reader :attachment, :text

    # @returns [Array<WorkProcess>]
    def import_work_processes(occupation_standard)
      JSON.parse(inferred_work_processes).map do |description, hour_bounds|
        WorkProcesses.import(occupation_standard:, description:, hour_bounds:)
      end
    end

    # @returns [String]
    def inferred_work_processes
      ChatGptGenerateText.new(prompt(:work_processes)).call
    end

    def prompt(key)
      "#{prompts(key)} #{text}"
    end

    def prompts(key)
      @prompts ||= {
        work_processes: "Identify the work processes and the hours spent in them in this " \
          "document as json with name of the process as key and hours as an array with the " \
          "values of minimum and maximum hours? If no work processes can be found, return an " \
          "empty json object without further explanation. Use 'N/A' when there is no hour, " \
          "and fill both values of the array with the same number when there is only one value " \
          "for hour. ",
        competencies: "Identify the competencies and the work processes they are " \
          "related to in this document as json with name of the competencies as key and " \
          "their related work processes as an array? Only consider something to be a competency " \
          "if clearly marked as one; if none can be found, return an empty json object without " \
          "further explanation. Use an empty array where there are no related work processes. "
      }

      @prompts.fetch(key)
    end
  end
end
