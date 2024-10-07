FactoryBot.define do
  factory :text_representation do
    data_import
    content { "PDF content" }
    document_sha { "7e7f04c8b5646f7ad29b1cb0c8085d4ff9c6b08f2a632f496641b31f524c7b98" }
  end
end
