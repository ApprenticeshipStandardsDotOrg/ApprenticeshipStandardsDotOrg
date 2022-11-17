require "rails_helper"

RSpec.describe "StandardsImports", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get new_standards_import_path

      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates new standards import record and redirects to show page" do
        expect {
          post standards_imports_path, params: {
            standards_import: {
              name: "Mickey Mouse",
              email: "mickey@mouse.com",
              organization: "Disney",
              notes: "a" * 500,
              files: [fixture_file_upload("spec/fixtures/files/pixel1x1.jpg", "image/jpeg")]
            }
          }
        }.to change(StandardsImport, :count).by(1)
          .and change(ActiveStorage::Attachment, :count).by(1)

        si = StandardsImport.last
        expect(si.name).to eq "Mickey Mouse"
        expect(si.email).to eq "mickey@mouse.com"
        expect(si.organization).to eq "Disney"
        expect(si.notes).to eq "a" * 500
        expect(si.files.count).to eq 1

        expect(response).to redirect_to standards_import_path(si)
      end
    end

    context "with invalid parameters" do
      it "does not create new standards import record and renders new" do
        allow_any_instance_of(StandardsImport).to receive(:save).and_return(false)
        expect {
          post standards_imports_path, params: {
            standards_import: {
              name: "Mickey Mouse",
              email: "mickey@mouse.com",
              organization: "Disney",
              notes: "a" * 500
            }
          }
        }.to_not change(StandardsImport, :count)

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET /show" do
    it "returns http success" do
      si = create(:standards_import)
      get standards_import_path(si)

      expect(response).to be_successful
    end
  end
end
