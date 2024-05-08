require "rails_helper"

RSpec.describe "Admin::DataImports", type: :request, admin: true do
  describe "GET /new" do
    context "when admin" do
      it "when import flag off: returns http success" do
        admin = create(:admin)
        source_file = create(:source_file)

        sign_in admin
        get new_admin_source_file_data_import_path(source_file)

        expect(response).to be_successful
      end

      it "when import flag on: returns http success" do
        stub_feature_flag(:show_imports_in_administrate, true)

        admin = create(:admin)
        imports_pdf = create(:imports_pdf)

        sign_in admin
        get new_admin_import_data_import_path(imports_pdf)

        expect(response).to be_successful

        stub_feature_flag(:show_imports_in_administrate, false)
      end
    end

    context "when converter" do
      it "when import flag off: returns http success" do
        admin = create(:user, :converter)
        source_file = create(:source_file)

        sign_in admin
        get new_admin_source_file_data_import_path(source_file)

        expect(response).to be_successful
      end

      it "when import flag on: returns http success" do
        stub_feature_flag(:show_imports_in_administrate, true)

        admin = create(:user, :converter)
        imports_pdf = create(:imports_pdf)

        sign_in admin
        get new_admin_import_data_import_path(imports_pdf)

        expect(response).to be_successful

        stub_feature_flag(:show_imports_in_administrate, false)
      end
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      context "when admin" do
        it "when import flag off: creates new data import record, calls parse job, and redirects to show page" do
          admin = create(:admin)
          source_file = create(:source_file)

          sign_in admin
          expect(ProcessDataImportJob).to receive(:perform_later).with(data_import: kind_of(DataImport), last_file: true)
          expect {
            post admin_source_file_data_imports_path(source_file), params: {
              data_import: {
                description: "A new occupation standard",
                file: fixture_file_upload("comp-occupation-standards-template.xlsx", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
              },
              last_file: "1"
            }
          }.to change(DataImport, :count).by(1)
            .and change(ActiveStorage::Attachment, :count).by(1)

          di = DataImport.last
          expect(di.source_file).to eq source_file
          expect(di.description).to eq "A new occupation standard"
          expect(di.file).to be

          expect(response).to redirect_to admin_source_file_data_import_path(source_file, di)
        end

        it "when import flag on: creates new data import record, calls parse job, and redirects to show page" do
          stub_feature_flag(:show_imports_in_administrate, true)

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

          stub_feature_flag(:show_imports_in_administrate, false)
        end
      end

      context "when converter" do
        it "when import flag off: creates new data import record, calls parse job, and redirects to show page" do
          admin = create(:user, :converter)
          source_file = create(:source_file)

          sign_in admin
          expect(ProcessDataImportJob).to receive(:perform_later).with(data_import: kind_of(DataImport), last_file: true)
          expect {
            post admin_source_file_data_imports_path(source_file), params: {
              data_import: {
                description: "A new occupation standard",
                file: fixture_file_upload("comp-occupation-standards-template.xlsx", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
              },
              last_file: "1"
            }
          }.to change(DataImport, :count).by(1)
            .and change(ActiveStorage::Attachment, :count).by(1)

          di = DataImport.last
          expect(di.source_file).to eq source_file
          expect(di.description).to eq "A new occupation standard"
          expect(di.file).to be

          expect(response).to redirect_to admin_source_file_data_import_path(source_file, di)
        end

        it "when import flag on: creates new data import record, calls parse job, and redirects to show page" do
          stub_feature_flag(:show_imports_in_administrate, true)

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

          stub_feature_flag(:show_imports_in_administrate, false)
        end
      end
    end

    context "with invalid parameters" do
      it "with import flag off: does not create new data import record and renders new" do
        admin = create(:admin)
        source_file = create(:source_file)

        sign_in admin
        allow_any_instance_of(DataImport).to receive(:save).and_return(false)
        expect {
          post admin_source_file_data_imports_path(source_file), params: {
            data_import: {
              description: "Description"
            }
          }
        }.to_not change(DataImport, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "with import flag on: does not create new data import record and renders new" do
        stub_feature_flag(:show_imports_in_administrate, true)

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

        expect(response).to have_http_status(:unprocessable_entity)

        stub_feature_flag(:show_imports_in_administrate, false)
      end
    end
  end

  describe "GET /show" do
    context "when admin" do
      it "with import flag off: returns http success" do
        admin = create(:admin)
        data_import = create(:data_import)
        source_file = data_import.source_file

        sign_in admin
        get admin_source_file_data_import_path(source_file, data_import)

        expect(response).to be_successful
      end

      it "with import flag on: returns http success" do
        stub_feature_flag(:show_imports_in_administrate, true)

        admin = create(:admin)
        imports_pdf = create(:imports_pdf)
        data_import = create(:data_import, import: imports_pdf)

        sign_in admin
        get admin_import_data_import_path(imports_pdf, data_import)

        expect(response).to be_successful

        stub_feature_flag(:show_imports_in_administrate, false)
      end
    end

    context "when converter" do
      it "with import flag off: returns http success" do
        admin = create(:user, :converter)
        data_import = create(:data_import)
        source_file = data_import.source_file

        sign_in admin
        get admin_source_file_data_import_path(source_file, data_import)

        expect(response).to be_successful
      end

      it "with import flag on: returns http success" do
        stub_feature_flag(:show_imports_in_administrate, true)

        admin = create(:user, :converter)
        imports_pdf = create(:imports_pdf)
        data_import = create(:data_import, import: imports_pdf)

        sign_in admin
        get admin_import_data_import_path(imports_pdf, data_import)

        expect(response).to be_successful

        stub_feature_flag(:show_imports_in_administrate, false)
      end
    end
  end

  describe "DELETE /destroy" do
    context "when admin" do
      it "with import flag off: deletes record and redirects to new page" do
        admin = create(:admin)
        data_import = create(:data_import)
        source_file = data_import.source_file

        sign_in admin
        expect {
          delete admin_source_file_data_import_path(source_file, data_import)
        }.to change(DataImport, :count).by(-1)
        expect(response).to redirect_to(admin_source_file_path(source_file))
      end

      it "with import flag on: deletes record and redirects to new page" do
        stub_feature_flag(:show_imports_in_administrate, true)

        admin = create(:admin)
        imports_pdf = create(:imports_pdf)
        data_import = create(:data_import, import: imports_pdf)

        sign_in admin
        expect {
          delete admin_import_data_import_path(imports_pdf, data_import)
        }.to change(DataImport, :count).by(-1)
        expect(response).to redirect_to(admin_import_path(imports_pdf))

        stub_feature_flag(:show_imports_in_administrate, false)
      end
    end

    context "when converter" do
      it "with import flag off: does not delete record" do
        admin = create(:user, :converter)
        data_import = create(:data_import)
        source_file = data_import.source_file

        sign_in admin
        expect {
          delete admin_source_file_data_import_path(source_file, data_import)
        }.to_not change(DataImport, :count)
        expect(response).to redirect_to root_path
      end

      it "with import flag on: does not delete record" do
        stub_feature_flag(:show_imports_in_administrate, true)

        admin = create(:user, :converter)
        imports_pdf = create(:imports_pdf)
        data_import = create(:data_import, import: imports_pdf)

        sign_in admin
        expect {
          delete admin_import_data_import_path(imports_pdf, data_import)
        }.to_not change(DataImport, :count)
        expect(response).to redirect_to root_path

        stub_feature_flag(:show_imports_in_administrate, false)
      end
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
          get edit_admin_source_file_data_import_path(source_file, data_import)

          expect(response).to be_successful
        end
      end

      context "when converter" do
        it "redirects" do
          admin = create(:user, :converter)
          data_import = create(:data_import)
          source_file = data_import.source_file

          sign_in admin
          get edit_admin_source_file_data_import_path(source_file, data_import)

          expect(response).to redirect_to root_path
        end
      end

      context "when guest" do
        it "redirects to root path" do
          data_import = create(:data_import)
          source_file = data_import.source_file

          get edit_admin_source_file_data_import_path(source_file, data_import)

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
          expect(ProcessDataImportJob).to receive(:perform_later).with(data_import: data_import, last_file: false)
          patch admin_source_file_data_import_path(source_file, data_import),
            params: {
              data_import: {
                description: "A new description"
              }
            }

          expect(data_import.reload.description).to eq "A new description"
          expect(response).to redirect_to admin_source_file_data_import_path(source_file, data_import)
        end
      end

      context "when converter" do
        it "does not update and redirects" do
          admin = create(:user, :converter)
          data_import = create(:data_import, description: "old description")
          source_file = data_import.source_file

          sign_in admin
          expect(ProcessDataImportJob).to_not receive(:perform_later)
          patch admin_source_file_data_import_path(source_file, data_import),
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
          data_import = create(:data_import, occupation_standard: occupation_standard)
          source_file = data_import.source_file
          create(:data_import, occupation_standard: occupation_standard, source_file: source_file)

          sign_in admin
          expect {
            delete admin_source_file_data_import_path(source_file, data_import)
          }.to change(DataImport, :count).by(-1)
            .and change(OccupationStandard, :count).by(0)

          expect(response).to redirect_to(admin_source_file_path(source_file))
        end
      end

      context "when occupation standard has no other data imports" do
        it "destroys record and destroys occupation standard" do
          admin = create(:admin)
          occupation_standard = create(:occupation_standard)
          data_import = create(:data_import, occupation_standard: occupation_standard)
          source_file = data_import.source_file

          sign_in admin
          expect {
            delete admin_source_file_data_import_path(source_file, data_import)
          }.to change(DataImport, :count).by(-1)
            .and change(OccupationStandard, :count).by(-1)

          expect(response).to redirect_to(admin_source_file_path(source_file))
        end
      end

      context "when data_import is not linked to occupation standard" do
        it "destroys record" do
          admin = create(:admin)
          data_import = create(:data_import, occupation_standard: nil)
          source_file = data_import.source_file

          sign_in admin
          expect {
            delete admin_source_file_data_import_path(source_file, data_import)
          }.to change(DataImport, :count).by(-1)
            .and change(OccupationStandard, :count).by(0)

          expect(response).to redirect_to(admin_source_file_path(source_file))
        end
      end
    end

    context "when converter" do
      it "does not destroy and redirects" do
        admin = create(:user, :converter)
        data_import = create(:data_import)
        source_file = data_import.source_file

        sign_in admin
        expect {
          delete admin_source_file_data_import_path(source_file, data_import)
        }.to change(DataImport, :count).by(0)
          .and change(OccupationStandard, :count).by(0)

        expect(response).to redirect_to root_path
      end
    end
  end
end
