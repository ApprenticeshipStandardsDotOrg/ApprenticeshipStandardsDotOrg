FactoryBot.define do
  factory :imports_uncategorized, class: Imports::Uncategorized do
    parent factory: :standards_import
    type { "Imports::Uncategorized" }
    file { Rack::Test::UploadedFile.new(Rails.root.join("spec", "fixtures", "files", "pixel1x1.pdf"), "application/pdf") }
  end

  factory :imports_docx_listing, class: Imports::DocxListing do
    parent factory: :imports_uncategorized
    type { "Imports::DocxListing" }
    file { Rack::Test::UploadedFile.new(Rails.root.join("spec", "fixtures", "files", "docx_file_attachments.docx")) }
  end

  factory :imports_docx, class: Imports::Docx do
    parent factory: :imports_uncategorized
    type { "Imports::Docx" }
    file { Rack::Test::UploadedFile.new(Rails.root.join("spec", "fixtures", "files", "document.docx")) }
  end

  factory :imports_pdf, class: Imports::Pdf do
    parent factory: :imports_uncategorized
    type { "Imports::Pdf" }
    file { Rack::Test::UploadedFile.new(Rails.root.join("spec", "fixtures", "files", "pixel1x1.pdf"), "application/pdf") }
  end
end
