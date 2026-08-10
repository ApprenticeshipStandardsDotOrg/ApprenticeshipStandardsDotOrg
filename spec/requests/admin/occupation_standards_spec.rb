require "rails_helper"
require "csv"

RSpec.describe "Admin::OccupationStandard", type: :request do
  describe "GET /index" do
    context "on admin subdomain", :admin do
      context "when admin user" do
        it "returns http success" do
          admin = create(:admin)
          create_pair(:occupation_standard)

          sign_in admin
          get admin_occupation_standards_path

          expect(response).to be_successful
        end

        it "can search" do
          admin = create(:admin)

          sign_in admin
          get admin_occupation_standards_path(search: "foo")

          expect(response).to be_successful
        end

        it "can filter by sample set" do
          admin = create(:admin)
          sample_standard = create(:occupation_standard, title: "Sample Standard", sample_set: true)
          create(:occupation_standard, title: "Other Standard", sample_set: false)

          sign_in admin
          get admin_occupation_standards_path(search: "sample_set:true")

          expect(response).to be_successful
          expect(response.body).to include("Sample set")
          expect(response.body).to include(sample_standard.title)
          expect(response.body).not_to include("Other Standard")
        end

        it "can filter by source" do
          admin = create(:admin)
          ai_standard = create(:occupation_standard, title: "AI Standard", source: :ai_conversion)
          create(:occupation_standard, title: "Manual Standard", source: :manual_upload)

          sign_in admin
          get admin_occupation_standards_path(search: "source:ai_conversion")

          expect(response).to be_successful
          expect(response.body).to include(ai_standard.title)
          expect(response.body).not_to include("Manual Standard")
        end

        it "can combine sample set and source filters" do
          admin = create(:admin)
          rapids_sample = create(:occupation_standard, title: "RAPIDS Sample", sample_set: true, source: :rapids_api)
          create(:occupation_standard, title: "RAPIDS Non Sample", sample_set: false, source: :rapids_api)
          create(:occupation_standard, title: "AI Sample", sample_set: true, source: :ai_conversion)

          sign_in admin
          get admin_occupation_standards_path(search: "sample_set:true source:rapids_api")

          expect(response).to be_successful
          expect(response.body).to include(rapids_sample.title)
          expect(response.body).not_to include("RAPIDS Non Sample")
          expect(response.body).not_to include("AI Sample")
        end

        it "can generate a filtered sample set CSV report" do
          admin = create(:admin)
          oa_agency = create(:registration_agency, agency_type: :oa)
          saa_agency = create(:registration_agency, :saa, state: create(:state, name: "Alabama", abbreviation: "AL"))
          organization = create(:organization)

          time_standard = create(
            :occupation_standard,
            sample_set: true,
            source: :rapids_api,
            ojt_type: :time,
            registration_agency: oa_agency,
            organization: organization,
            onet_code: "13-1071.01",
            rapids_code: "0157"
          )
          create_list(:work_process, 2, occupation_standard: time_standard)
          create(:related_instruction, occupation_standard: time_standard)

          hybrid_standard = create(
            :occupation_standard,
            sample_set: true,
            source: :rapids_api,
            ojt_type: :hybrid,
            registration_agency: saa_agency,
            organization: nil,
            onet_code: nil,
            rapids_code: nil
          )
          create(:related_instruction, occupation_standard: hybrid_standard, sort_order: 1)
          create(:related_instruction, occupation_standard: hybrid_standard, sort_order: 2)

          create(:occupation_standard, sample_set: false, source: :rapids_api)
          create(:occupation_standard, sample_set: true, source: :ai_conversion)

          sign_in admin
          get sample_set_report_admin_occupation_standards_path(format: :csv, search: "source:rapids_api")

          csv = CSV.parse(response.body, headers: true)
          row = csv.first

          expect(response).to be_successful
          expect(response.media_type).to eq "text/csv"
          expect(row["total"]).to eq "2"
          expect(row["filters"]).to eq "source:rapids_api sample_set:true"
          expect(row["pct_ojt_time"]).to eq "50.0"
          expect(row["pct_ojt_hybrid"]).to eq "50.0"
          expect(row["pct_reg_agency"]).to eq "100.0"
          expect(row["pct_agency_oa"]).to eq "50.0"
          expect(row["pct_agency_saa"]).to eq "50.0"
          expect(row["pct_org"]).to eq "50.0"
          expect(row["pct_source_rapids"]).to eq "100.0"
          expect(row["pct_onet"]).to eq "50.0"
          expect(row["pct_rapids"]).to eq "50.0"
          expect(row["pct_work_proc"]).to eq "50.0"
          expect(row["avg_work_proc"]).to eq "2.0"
          expect(row["pct_rel_instr"]).to eq "100.0"
          expect(row["avg_rel_instr"]).to eq "1.5"
        end
      end

      context "when converter" do
        it "redirects to root path" do
          admin = create(:user, :converter)

          sign_in admin
          get admin_occupation_standards_path

          expect(response).to redirect_to root_path
        end
      end

      context "when guest" do
        it "redirects to root path" do
          get admin_occupation_standards_path

          expect(response).to redirect_to new_user_session_path
        end
      end
    end

    context "on non-admin subdomain" do
      it "has 404 response" do
        get admin_occupation_standards_path

        expect(response).to be_not_found
      end
    end
  end

  describe "GET /show/:id" do
    context "on admin subdomain", :admin do
      context "when admin user" do
        it "returns http success" do
          admin = create(:admin)
          data_import = create(:data_import)
          occupation_standard = data_import.occupation_standard

          sign_in admin
          get admin_occupation_standard_path(occupation_standard)

          expect(response).to be_successful
        end
      end

      context "when converter" do
        it "redirects to root path" do
          admin = create(:user, :converter)
          data_import = create(:data_import)
          occupation_standard = data_import.occupation_standard

          sign_in admin
          get admin_occupation_standard_path(occupation_standard)

          expect(response).to redirect_to root_path
        end
      end

      context "when guest" do
        it "redirects to root path" do
          occupation_standard = create(:occupation_standard)

          get admin_occupation_standard_path(occupation_standard)

          expect(response).to redirect_to new_user_session_path
        end
      end
    end

    context "on non-admin subdomain" do
      it "has 404 response" do
        occupation_standard = create(:occupation_standard)

        get admin_occupation_standard_path(occupation_standard)

        expect(response).to be_not_found
      end
    end
  end

  describe "GET /edit/:id" do
    context "on admin subdomain", :admin do
      context "when admin user" do
        it "returns http success" do
          admin = create(:admin)
          data_import = create(:data_import)
          occupation_standard = data_import.occupation_standard

          sign_in admin
          get edit_admin_occupation_standard_path(occupation_standard)

          expect(response).to be_successful
        end
      end

      context "when converter" do
        it "redirects to root path" do
          admin = create(:user, :converter)
          data_import = create(:data_import)
          occupation_standard = data_import.occupation_standard

          sign_in admin
          get edit_admin_occupation_standard_path(occupation_standard)

          expect(response).to redirect_to root_path
        end
      end

      context "when guest" do
        it "redirects to root path" do
          occupation_standard = create(:occupation_standard)

          get edit_admin_occupation_standard_path(occupation_standard)

          expect(response).to redirect_to new_user_session_path
        end
      end
    end

    context "on non-admin subdomain" do
      it "has 404 response" do
        occupation_standard = create(:occupation_standard)

        get edit_admin_occupation_standard_path(occupation_standard)

        expect(response).to be_not_found
      end
    end
  end

  describe "PUT /update/:id" do
    context "on admin subdomain", :admin do
      context "when admin user" do
        context "with valid params" do
          it "updates record and redirects to show page" do
            admin = create(:admin)
            occupation_standard = create(:occupation_standard, occupation: nil)

            sign_in admin
            patch admin_occupation_standard_path(occupation_standard),
              params: {
                occupation_standard: {
                  title: "New title",
                  onet_code: "123.45",
                  rapids_code: "98765",
                  status: "published"
                }
              }

            occupation_standard.reload
            expect(occupation_standard.title).to eq "New title"
            expect(occupation_standard.onet_code).to eq "123.45"
            expect(occupation_standard.rapids_code).to eq "98765"
            expect(occupation_standard).to be_published
            expect(response).to redirect_to admin_occupation_standard_path(occupation_standard)
          end
        end

        context "with invalid params" do
          it "updates record and redirects to index" do
            admin = create(:admin)
            occupation_standard = create(:occupation_standard, occupation: nil)
            create(:data_import, occupation_standard: occupation_standard)

            sign_in admin
            patch admin_occupation_standard_path(occupation_standard),
              params: {
                occupation_standard: {
                  title: "",
                  onet_code: "123.45",
                  rapids_code: "98765",
                  status: "published"
                }
              }

            occupation_standard.reload
            expect(occupation_standard.title).to_not be_blank
            expect(occupation_standard.onet_code).to_not eq "123.45"
            expect(occupation_standard.rapids_code).to_not eq "98765"
            expect(occupation_standard).to be_importing
            expect(response).to have_http_status(:unprocessable_content)
          end
        end
      end
    end
  end

  describe "POST /create" do
    context "on admin subdomain", :admin do
      context "when admin user" do
        it "creates record with associations and redirects to show page" do
          admin = create(:admin)
          import = create(:imports_pdf)

          registration_agency = create(:registration_agency)
          occupation_standard_attributes = attributes_for(:occupation_standard).tap do |attrs|
            attrs[:registration_agency_id] = registration_agency.id
            attrs[:import_id] = import.id
            attrs[:open_ai_response] = "{}"
          end

          sign_in admin
          post admin_occupation_standards_path,
            params: {
              occupation_standard: occupation_standard_attributes.except(:url)
            }

          occupation_standard = OccupationStandard.last

          expect(response).to redirect_to admin_occupation_standard_path(occupation_standard)
          expect(occupation_standard.open_ai_import).to_not be_nil
          expect(occupation_standard).to be_published

          open_ai_import = occupation_standard.open_ai_import

          expect(open_ai_import.response).to eq "{}"
          expect(open_ai_import.import_id).to eq import.id
          expect(import.reload).to be_archived
        end
      end
    end
  end
end
