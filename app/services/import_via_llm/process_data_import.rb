module ImportViaLLM
  class ProcessDataImport
    attr_reader :attachment #, :text

    def initialize(attachment:)
      @attachment = attachment
      # @text = PdfFile.text(attachment)
      @ai = LLM.new
      # @appendix_a = determine_appendix_a
    end

    # def appendix_a?
    #   @appendix_a
    # end

    # TODO: collect occupation_standard from document
    def work_processes(occupation_standard)
      @work_processes ||= import_work_processes(occupation_standard)
    end

    private

    attr_reader :ai

    # def determine_appendix_a
    #   answer = ai.chat(prompt(:appendix_a))
    #   ActiveModel::Type::Boolean.new.cast(answer&.downcase)
    # end

    # @returns [Array<WorkProcess>]
    def import_work_processes(occupation_standard)
      # if appendix_a?
        JSON.parse(inferred_work_processes).map do |description, hour_bounds|
          WorkProcesses.import(occupation_standard:, description:, hour_bounds:)
        end
      # else
      #   []
      # end
    end

    # @returns [String]
    def inferred_work_processes
      questions = [
        "Determine if this file is an 'Appendix A' or has an 'Appendix A'. Remember your answer for " \
        "later.",

        "If this file is an 'Appendix A' or has an 'Appendix A', exclude all sections or tables " \
        "referring to training hours or on-the-job training. Treat the resulting document as a new " \
        "working document without those sections or tables for my next question.",

        "What working processes (and their hours) do you find in the resulting document from my " \
        "last question?",

        "If there are no work processes found from the last question, return a plain, empty JSON string " \
        "(without markdown), with no further explanation. " \
        "Otherwise, without any explanation, produce a plain JSON string (without markdown) " \
        "where each " \
        "key is the name of the work process found, and the key's value is an array with the " \
        "values of minimum and maximum hours. Use 'N/A' when there no hours specified and file " \
        "both values of the array with the same number when there is only one value for hours.",

        "Reformat the answer from the last question to remove any display formatting or markdown " \
        "formatting so that it may be directly parsed programmatically."
      ]
      result = LLM.as_assistant do |asst|
        asst.upload(filepath: attachment.to_s, key: 'attachment')
        (0..1).each {|idx| asst.post(questions[idx], file_keys: ['attachment']) }
        questions[2..-1].each {|qu| asst.post(qu) }
      end

      # ai.chat(prompt(:work_processes))
    end

    def prompt(key)
      "#{prompts(key)} Here is the document: #{text}"
    end

    # without any other explanation
    def prompts(key)
      @prompts ||= {
        appendix_a: <<~PROMPT,
          Is the following document an 'Appendix A' or does it have an 'Appendix A'?
          Answer only either 'true' or 'false', without further explanation.
        PROMPT

        work_processes: <<~PROMPT,
          You will be processing a document that is given after these instructions. For every step
          below, you will produce a new working document from which to proceed to use for the next
          step. After Step 1, you are to completely forget the original document and consider it
          at all in any subsequent step.

          Step 1: Locate any tables, sections, lists, or pages that are labelled with any
          variation of the phrases "training hours" or "on-the-job training". These phrases will be
          referred to now as the Target Phrases. Any found instance of the Target Phrases will be
          referred to as a Candidate Phrase. Consider the Target Phrases to have been found where a
          Candidate Phrase has any of the Target Phrases in any case or when hyphens are not
          included. Consider the Target Phrases to have been found where a Candidate Phrase may
          include variations that do not exactly match the either of the Target Phrases. Consider
          the Target Phrases to have been found where a Candidate Phrase includes variations of
          either of the Target Phrases when the words found are concatenated without spaces.
          Mark the starting location of each located document portion
          with ">>>!!! START EXCLUSION !!!<<<".
          Mark the ending location of each located document portion
          with "<<<!!! END EXCLUSION !!!>>>".

          Step 2: From the working document produced by Step 1 above, remove all content between
          each pair of ">>>!!! START EXCLUSION !!!<<<" and "<<<!!! END EXCLUSION !!!>>>".

          Step 3: From the working document produced by Step 2 above, any section, list, or page
          not labelled as "Work Processes" (or near variations of that text) should be excluded.

          Step 4: The result of Step 3 will be the only working document considered for the
          remainder of these steps. Solely from the result of Step 3 above, identify any work
          processes and the hours spent in them.

          Step 5: If no work processes were identified in Step 4 above, return an empty JSON
          string and abort further processing, ignoring the remaining
          steps.

          Step 6: From the result of Step 5 above where work processes and hours spent in them
          were found, produce a JSON string where each key is the name of the work process, and
          the key's value is an array with the values of minimum and maximum hours. Use 'N/A' when
          there are no hours specified, and fill both values of the array with the same number when
          there is only one value for hours.

          Step 7: From the result of Step 6, return the JSON string produced and abort further
          processing. Why didn't you remove any sections before Step 3?
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
