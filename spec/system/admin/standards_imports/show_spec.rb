require "rails_helper"

RSpec.describe "admin/standards_imports/show" do
  it "lists source_files", :admin do
    source_file = create(:source_file, :docx)
    import = source_file.standards_import
    admin = create(:admin)

    login_as admin
    visit admin_standards_import_path(import)

    expect(page).to have_link source_file.filename.to_s, href: admin_source_file_path(source_file)
  end
end
