class ImportDataFromRAPIDSJob < ApplicationJob
  queue_as :default

  include Sanitizable

  PER_PAGE_SIZE = 50
  MAXIMUM_TRIES = 5

  def perform
    @service = RAPIDS::API.call
    start_index = 1
    tries = 0

    begin
      loop do
        response = @service.work_processes(
          batchSize: PER_PAGE_SIZE,
          startIndex: start_index
        )
        parsed_response = response.parsed
        process_api_response(parsed_response)
        total_records = parsed_response["totalCount"]
        start_index += PER_PAGE_SIZE

        break if start_index > total_records
      end
    rescue OAuth2::Error
      if tries < MAXIMUM_TRIES
        @service.get_token!
        tries += 1
        Rails.logger.warn "[RAPIDSAPI] OAuth2::Error. Retrying #{tries} / #{MAXIMUM_TRIES}"
        retry
      else
        Rails.logger.warn "[RAPIDSAPI] Maximum tries reached"
      end
    end
  end

  def process_api_response(response)
    response["wps"].each do |occupation_standard_response|
      occupation_standard = process_occupation_standard(occupation_standard_response)

      next if occupation_standard.persisted?

      occupation_standard.work_processes = process_work_processes(
        occupation_standard_response["dwas"],
        occupation_standard
      )

      document = fetch_document_response(occupation_standard.external_id)
      if document
        attachment = convert_response_to_attachment(document)
        occupation_standard.redacted_document.attach(
          io: attachment, filename: "#{occupation_standard.external_id}.docx"
        )
      end
      occupation_standard.save
    end
  end

  def process_occupation_standard(occupation_standard_response)
    find_occupation_standard(occupation_standard_response) ||
      RAPIDS::OccupationStandard.initialize_from_response(
        occupation_standard_response
      )
  end

  def find_occupation_standard(occupation_standard_response)
    ::OccupationStandard.includes(:organization).find_by(
      title: fix_encoding(occupation_standard_response["occupationTitle"]),
      organization: {
        title: occupation_standard_response["sponsorName"]
      }
    )
  end

  def process_work_processes(work_processes_response, occupation_standard)
    work_processes_response.filter_map do |work_process_response|
      work_process = RAPIDS::WorkProcess.initialize_from_response(
        work_process_response,
        ojt_type: occupation_standard&.ojt_type&.to_sym
      )
      work_process.occupation_standard = occupation_standard
      work_process if work_process.valid?
    end
  end

  def fetch_document_response(external_id)
    response = @service.documents(wps_id: external_id)
    response&.body
  end

  def convert_response_to_attachment(document_response)
    attachment = StringIO.new(document_response)
    attachment.set_encoding Encoding::BINARY
    attachment
  end
end
