class PdfReaderJob < ApplicationJob
  queue_as :default

  def perform(import_id:, open_ai_prompt: OpenAIPrompt.default, force: false)
    pdf = Imports::Pdf.find(import_id)

    result = ConvertPdfImportWithAI.new(
      import: pdf,
      open_ai_prompt: open_ai_prompt,
      force: force
    ).call
    Rails.logger.warn("AI conversion for import #{pdf.id}: #{result.errors.join("; ")}") if result.errors.any?
    result
  end
end
