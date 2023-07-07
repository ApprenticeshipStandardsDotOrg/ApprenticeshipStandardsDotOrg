require "rails_helper"

RSpec.describe "StandardsImports", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get new_standards_import_path

      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters and decent Google recaptcha score" do
      context "when guest" do
        it "creates new standards import record, redirects to show page, and notifies admin" do
          stub_recaptcha_high_score

          expect_any_instance_of(StandardsImport).to receive(:notify_admin)
          expect {
            post standards_imports_path, params: {
              standards_import: {
                name: "Mickey Mouse",
                email: "mickey@mouse.com",
                organization: "Disney",
                notes: "a" * 500,
                files: [fixture_file_upload("spec/fixtures/files/pixel1x1.jpg", "image/jpeg")],
                public_document: true
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
          expect(si.public_document?).to be false

          expect(response).to redirect_to standards_import_path(si)
        end
      end

      context "when admin", :admin do
        it "creates new standards import record, redirects to source files page, and does not notify admin" do
          admin = create(:admin)

          sign_in admin
          expect_any_instance_of(StandardsImport).to_not receive(:notify_admin)
          expect {
            post standards_imports_path, params: {
              standards_import: {
                name: "Mickey Mouse",
                email: "mickey@mouse.com",
                organization: "Disney",
                notes: "a" * 500,
                files: [fixture_file_upload("spec/fixtures/files/pixel1x1.jpg", "image/jpeg")],
                public_document: true
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
          expect(si.public_document?).to be true

          expect(response).to redirect_to admin_source_files_path
        end
      end
    end

    context "with valid parameters and poor Google recaptcha score" do
      context "when guest" do
        it "does not create new standards import record" do
          stub_recaptcha_low_score

          expect_any_instance_of(StandardsImport).to_not receive(:notify_admin)
          expect {
            post standards_imports_path, params: {
              standards_import: {
                name: "Mickey Mouse",
                email: "mickey@mouse.com",
                organization: "Disney",
                notes: "a" * 500,
                files: [fixture_file_upload("spec/fixtures/files/pixel1x1.jpg", "image/jpeg")],
                public_document: true
              }
            }
          }.to_not change(StandardsImport, :count)

          expect(response).to redirect_to guest_root_path
        end
      end
    end

    context "with valid parameters and unsuccessful recaptcha score" do
      context "when guest" do
        it "does not create new standards import record and reports error" do
          stub_recaptcha_failure

          expect_any_instance_of(StandardsImport).to_not receive(:notify_admin)
          expect_any_instance_of(ErrorSubscriber).to receive(:report).and_call_original
          expect {
            post standards_imports_path, params: {
              standards_import: {
                name: "Mickey Mouse",
                email: "mickey@mouse.com",
                organization: "Disney",
                notes: "a" * 500,
                files: [fixture_file_upload("spec/fixtures/files/pixel1x1.jpg", "image/jpeg")],
                public_document: true
              }
            }
          }.to_not change(StandardsImport, :count)

          expect(response).to redirect_to guest_root_path
        end
      end
    end

    context "with invalid parameters" do
      it "does not create new standards import record and renders new" do
        stub_recaptcha_high_score

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
