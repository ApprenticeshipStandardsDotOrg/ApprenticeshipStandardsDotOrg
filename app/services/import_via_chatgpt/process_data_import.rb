module ImportViaChatgpt
  class ProcessDataImport
    def initialize(attachment:)
      @attachment = attachment
      @text = PdfFile.text(attachment)
    end

    def work_processes(occ, compdata)
      @work_processes ||= query_work_processes(occ, compdata)
    end

    private

    attr_reader :attachment, :text

    def query_work_processes(occ, compdata)
      response = ChatGptGenerateText.new(prompt(:work_processes)).call

      JSON.parse(response).each do |description, hour_bounds|
        WorkProcesses.extract(
          occupation_standard: occ,
          description:,
          hour_bounds:
        )
      end
    end

    def prompt(key)
      "#{prepended_prompt(:work_processes)} #{text}"
    end

    def prepended_prompt(key)
      @prepended_prompt ||= {
        work_processes: "Could you identify the work processes and the hours spent in them in this " \
          "document in a json with name of the process as key and hours as an array with the " \
          "values of minimum and maximum hours? Use 'N/A' when there is no hour, and fill both " \
          "values of the array with the same number when there is only one value for hour. "
      }

      @prepended_prompt.fetch(key)
    end
  end
end
