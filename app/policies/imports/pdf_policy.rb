class Imports::PdfPolicy < ImportPolicy
  def destroy_redacted_pdf?
    user.admin?
  end
end
