class GenerateOccupationStandardExportJob < ApplicationJob
  queue_as :default

  MIME_TYPE = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"

  def perform(occupation_standard)
    return if occupation_standard.working_copy_current?

    export = OccupationStandardExport.new(occupation_standard)
    version = occupation_standard.working_copy_version
    occupation_standard.working_copy_document.attach(
      io: StringIO.new(export.call),
      filename: export.filename,
      content_type: MIME_TYPE
    )
    blob = occupation_standard.working_copy_document.blob
    blob.update!(
      metadata: blob.metadata.merge("occupation_standard_version" => version)
    )
  ensure
    Rails.cache.delete("occupation-standard-working-copy/#{occupation_standard.id}")
  end
end
