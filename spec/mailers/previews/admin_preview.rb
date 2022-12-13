# Preview all emails at http://localhost:3000/rails/mailers/admin
class AdminPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/admin/new_standards_import
  def new_standards_import
    AdminMailer.new_standards_import
  end

end
