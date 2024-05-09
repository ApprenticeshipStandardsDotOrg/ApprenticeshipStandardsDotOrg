FactoryBot.define do
  factory :imports_uncategorized, class: Imports::Uncategorized do
    parent factory: :standards_import
    type { "Imports::Uncategorized" }
    file {
      Rack::Test::UploadedFile.new(Rails.root.join("spec", "fixtures", "files", "pixel1x1.pdf"), "application/pdf")
    }
    status { :unfurled }

    trait :docx_listing do
      file { Rack::Test::UploadedFile.new(Rails.root.join("spec", "fixtures", "files", "docx_file_attachments.docx")) }
    end

    trait :docx do
      file { Rack::Test::UploadedFile.new(Rails.root.join("spec", "fixtures", "files", "document.docx")) }
    end

    trait :doc do
      file { Rack::Test::UploadedFile.new(Rails.root.join("spec", "fixtures", "files", "document.doc")) }
    end

    trait :pdf do
      file {
        Rack::Test::UploadedFile.new(Rails.root.join("spec", "fixtures", "files", "pixel1x1.pdf"), "application/pdf")
      }
      status { :pending }
    end
  end

  factory :imports_docx_listing, class: Imports::DocxListing do
    parent factory: :imports_uncategorized
    type { "Imports::DocxListing" }
    file { Rack::Test::UploadedFile.new(Rails.root.join("spec", "fixtures", "files", "docx_file_attachments.docx")) }
    status { :unfurled }
  end

  factory :imports_docx, class: Imports::Docx do
    parent factory: :imports_uncategorized
    type { "Imports::Docx" }
    file { Rack::Test::UploadedFile.new(Rails.root.join("spec", "fixtures", "files", "document.docx")) }
    status { :unfurled }
  end

  factory :imports_doc, class: Imports::Doc do
    parent factory: :imports_uncategorized
    type { "Imports::Doc" }
    file { Rack::Test::UploadedFile.new(Rails.root.join("spec", "fixtures", "files", "document.doc")) }
    status { :unfurled }
  end

  factory :imports_pdf, class: Imports::Pdf do
    parent factory: :imports_uncategorized
    type { "Imports::Pdf" }
    file {
      Rack::Test::UploadedFile.new(Rails.root.join("spec", "fixtures", "files", "pixel1x1.pdf"), "application/pdf")
    }
    status { :pending }
  end
end
