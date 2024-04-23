class LLM
  class Assistant
    attr_reader :client

    def initialize(client: nil)
      @client = client || LLM.new

      # Assumption here is that the assistant and thread lifetimes will be the same as
      # the client in use, so no need to clean this up, since the owning client will be garbage
      # collected. However, #cleanup can be called if this assistant was established with
      # a preexisting LLM instance
      @assistant = create_assistant
      @thread = create_thread

      @files = {}
      @messages = { posted: [], resulting: [] }
      @destroyed = false
    end

    # @params filepath [String] Path to file for upload
    # @param key [String, Symbol] Key for referencing the file later
    def upload(filepath:, key:)
      abort_if_destroyed

      files[key] = client.upload(filepath, purpose: "assistants")
    end

    # @params message [String] Text to post
    # @params file_keys [Array<String|Symbol>] Keys of file(s) to associate with posted text
    def post(message, file_keys: [])
      abort_if_destroyed

      messages.fetch(:posted) << client.messages.create(
        thread_id:,
        parameters: {
          role: "user",
          content: message,
          file_ids: file_ids(file_keys:)
        }
      )
    end

    # Helper to drive an entire run, awaiting the results and reporting them
    # @return [Array<Hash>] Content received from remote LLM service
    # @raise [LLM::Assistant::RunFailedError] when run cancelled, failed, or expired on remote service
    # @raise [LLM::Assistant::UnknownRunStatusError] when remote service responses with an unexpected status
    # @note Right now this just polls (per their documentation); perhaps there's an event-driven solution
    def await_results
      start_run
      loop do
        break if check_run == :completed
        sleep 1.second
      end
      results
    end
    alias_method :await, :await_results

    def start_run
      abort_if_destroyed

      @run = client.runs.create(thread_id:, parameters: { assistant_id: })
    end

    # Collect present state of assistant run, retrieving any results or handling exceptions
    # @return [Symbol] Run status
    # @raise [LLM::Assistant::RunFailedError] when cancelled, failed, or expired on remote service
    # @raise [LLM::Assistant::UnknownRunStatusError] when remote service responses with an unexpected status
    def check_run
      abort_if_destroyed

      response = client.runs.retrieve(id: run_id, thread_id:)
      status = response.fetch("status")&.to_sym

      case status
      when :queued, :in_progress, :cancelling
        status
      when :completed
        close_run
        status
      when "cancelled", "failed", "expired"
        raise RunFailedError(status, response.fetch("last_error"))
      else
        raise UnknownRunStatusError, response.fetch("status", "-nil-")
      end
    end

    # Retrieve result from a completed run
    # @return [Array<Hash>] Content received from remote LLM service
    def results
      abort_if_destroyed

      messages.fetch(:resulting).flat_map do |msg|
        msg.fetch("content").flat_map do |item|
          case item.fetch("type")
          when "text"
            { text: item.dig("text", "value") }
          # when "image_file" # TODO: still to test/implement if needed
          #   id = content_item.dig("image_file", "file_id")
          when "unknown"
            { unknown: item }
          end
        end
      end
    end

    # Ensure anything posted to the LLM has been cleaned out from the run.
    # Not calling this may leave artifacts in the remote LLM service.
    def destroy!
      abort_if_destroyed

      files.values.each do |file|
        client.files.delete(id: file.fetch("id"))
      end
      files = nil

      messages.values do |message_type|
        message_type.each do |message|
          client.messages.delete(id: message.fetch("id"))
        end
      end
      messages = nil

      client.assistants.delete(id: assistant_id)
      @assistant = nil

      client.threads.delete(id: thread_id)
      @thread = nil

      @destroyed = true
    end

    # @return [true | false] Whether this assistant was already marked as destroyed (and so no longer viable)
    def destroyed?
      ActiveModel::Type::Boolean.new.cast(@destroyed)
    end

    private

    attr_reader :assistant, :thread, :files, :messages, :run

    def abort_if_destroyed
      raise DestroyedAssistantError if destroyed?
      destroyed?
    end

    def close_run
      steps = client.run_steps.list(thread_id:, run_id:)

      ids = steps.fetch("data").filter_map do |step|
        if step.fetch("type") == "message_creation"
          step.dig("step_details", "message_creation", "message_id")
        end
      end

      messages[:resulting] = ids.map { |id| client.messages.retrieve(id:, thread_id:) }.compact
    end

    def assistant_id
      assistant&.fetch("id")
    end

    def thread_id
      thread&.fetch("id")
    end

    def posted_message_ids
      messages.fetch(:posted).map{ _1.fetch("id") }
    end

    def run_id
      run&.fetch("id")
    end

    def file_ids(file_keys: [])
      files.values_at(*file_keys).map{ _1.fetch("id") }
    end

    def create_assistant
      client.assistants.create(
        parameters: {
          model: "gpt-4-turbo-preview",
          name: "LLM::Assistant",
          tools: [{ type: "retrieval" }]
        }
      )
    rescue Faraday::BadRequestError => e
      body = e.response.fetch(:body).fetch("error")
      raise LLM::InvalidRequestError, "(#{body['code']}) #{body['message']}"
    end

    def create_thread
      client.threads.create
    end

    class LLMAssistantError < StandardError; end
    class DestroyedAssistantError < LLMAssistantError
      def initialize(*args)
        super("This assistant instance has been marked as destroyed and is no longer valid for use.")
      end
    end
    class RunFailedError < LLMAssistantError
      def initialize(status, error)
        super("Run failed with status of \"#{status}\": \"#{error}\"")
      end
    end
    class UnknownRunStatusError < LLMAssistantError
      def initialize(status)
        super("Unknown run status \"#{status}\" received")
      end
    end
  end
end
