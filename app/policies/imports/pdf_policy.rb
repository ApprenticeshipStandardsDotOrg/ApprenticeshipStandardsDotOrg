class Imports::PdfPolicy < ImportPolicy
  def destroy_redacted_pdf?
    user.admin?
  end

  def convert_with_ai?
    admin_or_converter?
  end
end
