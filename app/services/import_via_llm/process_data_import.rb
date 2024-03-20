module ImportViaLLM
  class ProcessDataImport
    attr_reader :attachment, :text

    def initialize(attachment:)
      @attachment = attachment
      @text = PdfFile.text(attachment)
      @ai = LLM.new
      @appendix_a = determine_appendix_a
    end

    def appendix_a?
      @appendix_a
    end

    # TODO: collect occupation_standard from document
    def work_processes(occupation_standard)
      @work_processes ||= import_work_processes(occupation_standard)
    end

    private

    attr_reader :ai

    def determine_appendix_a
      answer = ai.chat(prompt(:appendix_a))
      ActiveModel::Type::Boolean.new.cast(answer&.downcase)
    end

    # @returns [Array<WorkProcess>]
    def import_work_processes(occupation_standard)
      if appendix_a?
        JSON.parse(inferred_work_processes).map do |description, hour_bounds|
          WorkProcesses.import(occupation_standard:, description:, hour_bounds:)
        end
      else
        []
      end
    end

    # @returns [String]
    def inferred_work_processes
      ai.chat(prompt(:work_processes))
    end

    def prompt(key)
      "#{prompts(key)} Here is the document: #{text}"
    end

    def prompts(key)
      @prompts ||= {
        appendix_a: <<~PROMPT,
          Is the following document an 'Appendix A' or does it have an 'Appendix A'?
          Answer only either 'true' or 'false', without further explanation.
        PROMPT

        work_processes: <<~PROMPT,
          You will be processing a document that is given after these instructions. For every step
          below, you will produce a new working document from which to proceed to use for the next
          step. After Step 1, you are to completely forget the original document.

          Step 1: Exclude any tables, sections, lists, or pages that are labelled with any
          variation of the phrases "training hours" or "on-the-job training". This exclusion is to
          also be applied where the label contains the phrase in any part of the label. This
          exclusion is to also be applied where the phrase detected within the label may not be
          lowercase or when hyphens are not included. This exclusion is to also be applied
          when the phrase does not exactly match "training hours". This exclusion is to also be
          applied even when the words of the phrase are concatenated without spaces.

          Step 2: From the working document produced by Step 1 above, any section, list, or page
          not labelled as "Work Processes" (or near variations of that text) should be excluded.

          Step 3: The result of Step 2 will be the only working document considered for the
          remainder of these steps. Solely from the result of Step 2 above, identify any work
          processes and the hours spent in them.

          Step 4: If no work processes were identified in Step 3 above, return an empty JSON
          string without any other explanation and abort further processing, ignoring the remaining
          steps.

          Step 5: From the result of Step 5 above where work processes and hours spent in them
          were found, produce a JSON string where each key is the name of the work process, and
          the key's value is an array with the values of minimum and maximum hours. Use 'N/A' when
          there are no hours specified, and fill both values of the array with the same number when
          there is only one value for hours.

          Step 7: From the result of Step 6, return the JSON string produced and abort further
          processing without further explanation.
        PROMPT
        # No explanations should be given
        # unless explicitly asked for by a given step.
        # Step 5: If you identified any work processes from Step 4, then the instructions were
        # not followed as intended. Please provide a complete explanation of how you followed
        # the rules,
        # including why the table "ON-THE-JOB TRAINING HOURS" was
        # not excluded by Step 1.

        # Why didn't you exclude the table labelled "ON-THE-JOB TRAINING HOURS"?
          # If I wanted to exclude that table, how should I have worded this prompt to do so?
        # work_processes: <<~PROMPT,
        #   Identify the work processes and the hours spent in them in the following document as JSON
        #     with name of the work process as key and hours as an array with the values of minimum
        #     and maximum hours.
        #   Work processes are identified only when they are in a list or page labelled 'Work Processes'
        #     (or near variations of the same text) but any sections or tables within with
        #     with labels that include the terms "on the job", "training", and "hours" in any
        #     variation, order or case are to be excluded from identification.
        #   If no work processes are identified, return an empty JSON object without further
        #     explanation.
        #   Use 'N/A' when there are no hours specified, and fill both values of the
        #     array with the same number when there is only one value for hours.
        #   Please explain how you identified these.
        #   Why didn't you exclude the table labelled "ON-THE-JOB TRAINING HOURS"?
        #   If I wanted to exclude that table, how should I have worded this prompt to do so?
        # PROMPT

        competencies: <<~PROMPT
          Identify the competencies and the work processes they are related to in this document
            as JSON with name of the competencies as key and their related work processes as an
            array?
          Only consider something to be a competency if clearly marked as one; if none can
            be found, return an empty JSON object without further explanation. Use an empty array
            where there are no related work processes.
        PROMPT
      }

      @prompts.fetch(key).gsub(/\s+/, " ").squish.strip
    end
  end
end
