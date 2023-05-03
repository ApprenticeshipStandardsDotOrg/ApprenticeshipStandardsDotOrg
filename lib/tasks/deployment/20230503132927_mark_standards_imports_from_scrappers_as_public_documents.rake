namespace :after_party do
  desc "Deployment task: mark_standards_imports_from_scrappers_as_public_documents"
  task mark_standards_imports_from_scrappers_as_public_documents: :environment do
    puts "Running deploy task 'mark_standards_imports_from_scrappers_as_public_documents'"

    StandardsImport.where("notes ILIKE '%From Scraper%'").update_all(public_document: true)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
