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
          stub_feature_flag(:recaptcha, true)
          stub_recaptcha_high_score

          file1 = fixture_file_upload("pixel1x1.pdf")
          file2 = fixture_file_upload("pixel1x1_redacted.pdf")
          expect_any_instance_of(StandardsImport).to receive(:notify_admin)
          expect {
            post standards_imports_path, params: {
              standards_import: {
                name: "Mickey Mouse",
                email: "mickey@mouse.com",
                organization: "Disney",
                notes: "a" * 500,
                files: [file1, file2],
                public_document: true
              }
            }
          }.to change(StandardsImport, :count).by(1)
            .and change(ActiveStorage::Attachment, :count).by(4)
            .and change(ActiveStorage::Blob, :count).by(2)
            .and change(Imports::Uncategorized, :count).by(2)

          si = StandardsImport.last
          expect(si.name).to eq "Mickey Mouse"
          expect(si.email).to eq "mickey@mouse.com"
          expect(si.organization).to eq "Disney"
          expect(si.notes).to eq "a" * 500
          expect(si.files.count).to eq 2
          expect(si.public_document?).to be false
          expect(si).to be_courtesy_notification_pending

          import1 = Imports::Uncategorized.first
          expect(import1).to be_courtesy_notification_pending
          expect(import1.file.blob.filename.to_s).to eq "pixel1x1.pdf"
          expect(import1).to be_unfurled
          expect(import1).to_not be_public_document
          expect(import1.parent).to eq si

          import2 = Imports::Uncategorized.last
          expect(import2).to be_courtesy_notification_pending
          expect(import2.file.blob.filename.to_s).to eq "pixel1x1_redacted.pdf"
          expect(import1).to be_unfurled
          expect(import2).to_not be_public_document
          expect(import2.parent).to eq si

          expect(response).to redirect_to standards_import_path(si)
        end
      end

      context "when admin", :admin do
        it "creates new standards import record, redirects to source files page, and does not notify admin" do
          stub_feature_flag(:recaptcha, true)
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
                files: [fixture_file_upload("pixel1x1.pdf")],
                public_document: true
              }
            }
          }.to change(StandardsImport, :count).by(1)
            .and change(ActiveStorage::Attachment, :count).by(2)
            .and change(ActiveStorage::Blob, :count).by(1)
            .and change(Imports::Uncategorized, :count).by(1)

          si = StandardsImport.last
          expect(si.name).to eq "Mickey Mouse"
          expect(si.email).to eq "mickey@mouse.com"
          expect(si.organization).to eq "Disney"
          expect(si.notes).to eq "a" * 500
          expect(si.files.count).to eq 1
          expect(si.public_document?).to be true
          expect(si).to be_courtesy_notification_not_required

          import = Imports::Uncategorized.last
          expect(import).to be_courtesy_notification_not_required
          expect(import.file.blob.filename.to_s).to eq "pixel1x1.pdf"
          expect(import).to be_unfurled
          expect(import).to be_public_document

          expect(response).to redirect_to admin_source_files_path
        end
      end
    end

    context "with valid parameters and poor Google recaptcha score" do
      context "when guest" do
        it "does not create new standards import record" do
          stub_feature_flag(:recaptcha, true)
          stub_recaptcha_low_score

          expect_any_instance_of(StandardsImport).to_not receive(:notify_admin)
          expect {
            post standards_imports_path, params: {
              standards_import: {
                name: "Mickey Mouse",
                email: "mickey@mouse.com",
                organization: "Disney",
                notes: "a" * 500,
                files: [fixture_file_upload("pixel1x1.pdf")],
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
          stub_feature_flag(:recaptcha, true)
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
                files: [fixture_file_upload("pixel1x1.pdf")],
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
        stub_feature_flag(:recaptcha, true)
        stub_recaptcha_high_score

        expect {
          post standards_imports_path, params: {
            standards_import: {
              name: "",
              email: "",
              organization: "Disney",
              notes: "a" * 500
            }
          }
        }.to_not change(StandardsImport, :count)

        expect(response).to have_http_status(:unprocessable_content)

        stub_feature_flag(:recaptcha, false)
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
