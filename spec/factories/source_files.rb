FactoryBot.define do
  factory :source_file do
    traits_for_enum :status, SourceFile.statuses

    #active_storage_attachment do 
    #  #build(:active_storage_attachment, record: standards_import, source_file: instance)
    #  build(:active_storage_attachment, source_file: instance)
    #end
  end
end
