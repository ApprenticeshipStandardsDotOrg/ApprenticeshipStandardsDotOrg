require "rails_helper"

RSpec.describe "Admin::DataImports", type: :request, admin: true do
  describe "GET /new" do
    context "when admin" do
      it "returns http success" do
        admin = create(:admin)
        imports_pdf = create(:imports_pdf)

        sign_in admin
        get new_admin_import_data_import_path(imports_pdf)

        expect(response).to be_successful
      end
    end

    context "when converter" do
      it "returns http success" do
        admin = create(:user, :converter)
        imports_pdf = create(:imports_pdf)

        sign_in admin
        get new_admin_import_data_import_path(imports_pdf)

        expect(response).to be_successful
      end
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      context "when admin" do
        it "creates new data import record, calls parse job, and redirects to show page" do
          admin = create(:admin)
          imports_pdf = create(:imports_pdf)

          sign_in admin
          expect(ProcessDataImportJob).to receive(:perform_later).with(data_import: kind_of(DataImport), last_file: true)
          expect {
            post admin_import_data_imports_path(imports_pdf), params: {
              data_import: {
                description: "A new occupation standard",
                file: fixture_file_upload("comp-occupation-standards-template.xlsx", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
              },
              last_file: "1"
            }
          }.to change(DataImport, :count).by(1)
            .and change(ActiveStorage::Attachment, :count).by(1)

          di = DataImport.last
          expect(di.source_file).to be_nil
          expect(di.import).to eq imports_pdf
          expect(di.description).to eq "A new occupation standard"
          expect(di.file).to be

          expect(response).to redirect_to admin_import_data_import_path(imports_pdf, di)
        end
      end

      context "when converter" do
        it "creates new data import record, calls parse job, and redirects to show page" do
          admin = create(:user, :converter)
          imports_pdf = create(:imports_pdf)

          sign_in admin
          expect(ProcessDataImportJob).to receive(:perform_later).with(data_import: kind_of(DataImport), last_file: true)
          expect {
            post admin_import_data_imports_path(imports_pdf), params: {
              data_import: {
                description: "A new occupation standard",
                file: fixture_file_upload("comp-occupation-standards-template.xlsx", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
              },
              last_file: "1"
            }
          }.to change(DataImport, :count).by(1)
            .and change(ActiveStorage::Attachment, :count).by(1)

          di = DataImport.last
          expect(di.source_file).to be_nil
          expect(di.import).to eq imports_pdf
          expect(di.description).to eq "A new occupation standard"
          expect(di.file).to be

          expect(response).to redirect_to admin_import_data_import_path(imports_pdf, di)
        end
      end
    end

    context "with invalid parameters" do
      it "does not create new data import record and renders new" do
        admin = create(:admin)
        imports_pdf = create(:imports_pdf)

        sign_in admin
        allow_any_instance_of(DataImport).to receive(:save).and_return(false)
        expect {
          post admin_import_data_imports_path(imports_pdf), params: {
            data_import: {
              description: "Description"
            }
          }
        }.to_not change(DataImport, :count)

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "GET /show" do
    context "when admin" do
      it "returns http success" do
        admin = create(:admin)
        imports_pdf = create(:imports_pdf)
        data_import = create(:data_import, import: imports_pdf)

        sign_in admin
        get admin_import_data_import_path(imports_pdf, data_import)

        expect(response).to be_successful
      end
    end

    context "when converter" do
      it "returns http success" do
        admin = create(:user, :converter)
        imports_pdf = create(:imports_pdf)
        data_import = create(:data_import, import: imports_pdf)

        sign_in admin
        get admin_import_data_import_path(imports_pdf, data_import)

        expect(response).to be_successful
      end
    end
  end

  describe "DELETE /destroy" do
    context "when admin" do
      it "deletes record and redirects to new page" do
        admin = create(:admin)
        imports_pdf = create(:imports_pdf)
        data_import = create(:data_import, import: imports_pdf)

        sign_in admin
        expect {
          delete admin_import_data_import_path(imports_pdf, data_import)
        }.to change(DataImport, :count).by(-1)
        expect(response).to redirect_to(admin_import_path(imports_pdf))
      end
    end

    context "when converter" do
      it "does not delete record" do
        admin = create(:user, :converter)
        imports_pdf = create(:imports_pdf)
        data_import = create(:data_import, import: imports_pdf)

        sign_in admin
        expect {
          delete admin_import_data_import_path(imports_pdf, data_import)
        }.to_not change(DataImport, :count)
        expect(response).to redirect_to root_path
      end
    end
  end

  describe "GET /edit/:id" do
    context "on admin subdomain" do
      context "when admin user" do
        it "returns http success" do
          admin = create(:admin)
          imports_pdf = create(:imports_pdf)
          data_import = create(:data_import, import: imports_pdf)

          sign_in admin
          get edit_admin_import_data_import_path(imports_pdf, data_import)

          expect(response).to be_successful
        end
      end

      context "when converter" do
        it "redirects" do
          admin = create(:user, :converter)
          imports_pdf = create(:imports_pdf)
          data_import = create(:data_import, import: imports_pdf)

          sign_in admin
          get edit_admin_import_data_import_path(imports_pdf, data_import)

          expect(response).to redirect_to root_path
        end
      end

      context "when guest" do
        it "redirects to root path" do
          imports_pdf = create(:imports_pdf)
          data_import = create(:data_import, import: imports_pdf)

          get edit_admin_import_data_import_path(imports_pdf, data_import)

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
          imports_pdf = create(:imports_pdf)
          data_import = create(:data_import, import: imports_pdf)

          sign_in admin
          expect(ProcessDataImportJob).to receive(:perform_later).with(data_import: data_import, last_file: false)
          patch admin_import_data_import_path(imports_pdf, data_import),
            params: {
              data_import: {
                description: "A new description"
              }
            }

          expect(data_import.reload.description).to eq "A new description"
          expect(response).to redirect_to admin_import_data_import_path(imports_pdf, data_import)
        end
      end

      context "when converter" do
        it "does not update and redirects" do
          admin = create(:user, :converter)
          imports_pdf = create(:imports_pdf)
          data_import = create(:data_import, import: imports_pdf, description: "old description")

          sign_in admin
          expect(ProcessDataImportJob).to_not receive(:perform_later)
          patch admin_import_data_import_path(imports_pdf, data_import),
            params: {
              data_import: {
                description: "A new description"
              }
            }

          expect(data_import.reload.description).to eq "old description"
          expect(response).to redirect_to root_path
        end
      end
    end
  end

  describe "DELETE /destroy/:id" do
    context "when admin user" do
      context "when occupation standard has other data imports" do
        it "destroys record and leaves occupation standard unchanged" do
          admin = create(:admin)
          occupation_standard = create(:occupation_standard)
          imports_pdf = create(:imports_pdf)
          data_import = create(:data_import, import: imports_pdf, occupation_standard: occupation_standard)
          create(:data_import, import: imports_pdf, occupation_standard: occupation_standard)

          sign_in admin
          expect {
            delete admin_import_data_import_path(imports_pdf, data_import)
          }.to change(DataImport, :count).by(-1)
            .and change(OccupationStandard, :count).by(0)

          expect(response).to redirect_to(admin_import_path(imports_pdf))
        end
      end

      context "when occupation standard has no other data imports" do
        it "destroys record and destroys occupation standard" do
          admin = create(:admin)
          occupation_standard = create(:occupation_standard)
          imports_pdf = create(:imports_pdf)
          data_import = create(:data_import, import: imports_pdf, occupation_standard: occupation_standard)

          sign_in admin
          expect {
            delete admin_import_data_import_path(imports_pdf, data_import)
          }.to change(DataImport, :count).by(-1)
            .and change(OccupationStandard, :count).by(-1)

          expect(response).to redirect_to(admin_import_path(imports_pdf))
        end
      end

      context "when data_import is not linked to occupation standard" do
        it "destroys record" do
          admin = create(:admin)
          imports_pdf = create(:imports_pdf)
          data_import = create(:data_import, import: imports_pdf, occupation_standard: nil)

          sign_in admin
          expect {
            delete admin_import_data_import_path(imports_pdf, data_import)
          }.to change(DataImport, :count).by(-1)
            .and change(OccupationStandard, :count).by(0)

          expect(response).to redirect_to(admin_import_path(imports_pdf))
        end
      end
    end

    context "when converter" do
      it "does not destroy and redirects" do
        admin = create(:user, :converter)
        imports_pdf = create(:imports_pdf)
        data_import = create(:data_import, import: imports_pdf)

        sign_in admin
        expect {
          delete admin_import_data_import_path(imports_pdf, data_import)
        }.to change(DataImport, :count).by(0)
          .and change(OccupationStandard, :count).by(0)

        expect(response).to redirect_to root_path
      end
    end
  end
end
