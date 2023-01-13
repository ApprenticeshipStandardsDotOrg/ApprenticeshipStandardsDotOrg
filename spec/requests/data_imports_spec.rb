require "rails_helper"

RSpec.describe "DataImports", type: :request, admin: true do
  describe "GET /new" do
    it "returns http success" do
      admin = create(:admin)
      
      sign_in admin
      get new_data_import_path

      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates new data import record and redirects to show page" do
        admin = create(:admin)
      
        sign_in admin
        expect {
          post data_imports_path, params: {
            data_import: {
              description: "A new occupation standard",
              file: fixture_file_upload("spec/fixtures/files/pixel1x1.jpg", "image/jpeg")
            }
          }
        }.to change(DataImport, :count).by(1)
          .and change(ActiveStorage::Attachment, :count).by(1)

        di = DataImport.last
        expect(di.description).to eq "A new occupation standard"
        expect(di.file).to be

        expect(response).to redirect_to data_import_path(di)
      end
    end

    context "with invalid parameters" do
      it "does not create new data import record and renders new" do
        admin = create(:admin)
      
        sign_in admin
        allow_any_instance_of(DataImport).to receive(:save).and_return(false)
        expect {
          post data_imports_path, params: {
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
      di = create(:data_import)
      
      sign_in admin
      get data_import_path(di)

      expect(response).to be_successful
    end
  end

  describe "DELETE /destroy" do
    it "deletes record and redirects to new page" do
      admin = create(:admin)
      di = create(:data_import)
      
      sign_in admin
      expect{ delete data_import_path(di) }.to change(DataImport, :count).by(-1)
      expect(response).to redirect_to(new_data_import_path)
    end
  end

  describe "GET /edit/:id" do
    context "on admin subdomain", :admin do
      context "when admin user" do
        it "returns http success" do
          admin = create(:admin)
          di = create(:data_import)

          sign_in admin
          get edit_data_import_path(di)

          expect(response).to be_successful
        end
      end

      context "when guest" do
        it "redirects to root path" do
          di = create(:data_import)
          get edit_file_import_path(di)

          expect(response).to redirect_to new_user_session_path
        end
      end
    end
  end

  describe "PUT /update/:id" do
    context "on admin subdomain", :admin do
      context "when admin user" do
        it "updates record and redirects to index" do
          admin = create(:admin)
          di = create(:data_import)

          sign_in admin
          di_params = {
            data_import: {
              description: "A new description"
            }
          }
          patch data_import_path(di), params: di_params
          expect(response).to redirect_to data_import_path(di)
        end
      end
    end
  end
end