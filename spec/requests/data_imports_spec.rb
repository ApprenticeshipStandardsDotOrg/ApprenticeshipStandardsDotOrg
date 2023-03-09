require "rails_helper"

RSpec.describe "DataImports", type: :request, admin: true do
  describe "GET /new" do
    it "returns http success" do
      admin = create(:admin)
      source_file = create(:source_file)

      sign_in admin
      get new_source_file_data_import_path(source_file)

      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates new data import record, calls parse job, and redirects to show page" do
        admin = create(:admin)
        source_file = create(:source_file)

        sign_in admin
        expect(ProcessDataImportJob).to receive(:perform_later).with(kind_of(DataImport))
        expect {
          post source_file_data_imports_path(source_file), params: {
            data_import: {
              description: "A new occupation standard",
              file: fixture_file_upload("spec/fixtures/files/pixel1x1.jpg", "image/jpeg")
            }
          }
        }.to change(DataImport, :count).by(1)
          .and change(ActiveStorage::Attachment, :count).by(1)

        di = DataImport.last
        expect(di.source_file).to eq source_file
        expect(di.description).to eq "A new occupation standard"
        expect(di.file).to be

        expect(response).to redirect_to source_file_data_import_path(source_file, di)
      end
    end

    context "with invalid parameters" do
      it "does not create new data import record and renders new" do
        admin = create(:admin)
        source_file = create(:source_file)

        sign_in admin
        allow_any_instance_of(DataImport).to receive(:save).and_return(false)
        expect {
          post source_file_data_imports_path(source_file), params: {
            data_import: {
              description: "Description"
            }
          }
        }.to_not change(DataImport, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /show" do
    it "returns http success" do
      admin = create(:admin)
      data_import = create(:data_import)
      source_file = data_import.source_file

      sign_in admin
      get source_file_data_import_path(source_file, data_import)

      expect(response).to be_successful
    end
  end

  describe "DELETE /destroy" do
    it "deletes record and redirects to new page" do
      admin = create(:admin)
      data_import = create(:data_import)
      source_file = data_import.source_file

      sign_in admin
      expect {
        delete source_file_data_import_path(source_file, data_import)
      }.to change(DataImport, :count).by(-1)
      expect(response).to redirect_to(new_source_file_data_import_path(source_file))
    end
  end

  describe "GET /edit/:id" do
    context "on admin subdomain" do
      context "when admin user" do
        it "returns http success" do
          admin = create(:admin)
          data_import = create(:data_import)
          source_file = data_import.source_file

          sign_in admin
          get edit_source_file_data_import_path(source_file, data_import)

          expect(response).to be_successful
        end
      end

      context "when guest" do
        it "redirects to root path" do
          data_import = create(:data_import)
          source_file = data_import.source_file

          get edit_source_file_data_import_path(source_file, data_import)

          expect(response).to redirect_to new_user_session_path
        end
      end
    end
  end

  describe "PUT /update/:id" do
    context "on admin subdomain" do
      context "when admin user" do
        it "updates record and redirects to index" do
          admin = create(:admin)
          data_import = create(:data_import)
          source_file = data_import.source_file

          sign_in admin
          expect(ProcessDataImportJob).to receive(:perform_later).with(data_import)
          patch source_file_data_import_path(source_file, data_import),
            params: {
              data_import: {
                description: "A new description"
              }
            }

          expect(data_import.reload.description).to eq "A new description"
          expect(response).to redirect_to source_file_data_import_path(source_file, data_import)
        end
      end
    end
  end
end
