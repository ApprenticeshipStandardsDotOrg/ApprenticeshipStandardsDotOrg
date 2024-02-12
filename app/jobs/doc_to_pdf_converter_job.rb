class DocToPdfConverterJob < ApplicationJob
  queue_as :default

  def perform(source_file)
    DocToPdfConverter.convert(source_file)
  end
end
