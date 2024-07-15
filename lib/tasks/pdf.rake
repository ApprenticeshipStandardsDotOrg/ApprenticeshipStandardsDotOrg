namespace :pdf do
  task archive_pdfs: :environment do
    PdfArchiveEvaluatorJob.perform_later
  end
end
