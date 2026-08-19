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
          manual_converter = create(:user, email: "converter@example.com")
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
          work_process_1 = create(:work_process, occupation_standard: time_standard, title: "Cut Metal", description: nil, maximum_hours: 100)
          work_process_2 = create(:work_process, occupation_standard: time_standard, title: "Weld Frame", description: nil, maximum_hours: 200)
          create(:competency, work_process: work_process_1, title: "Inspect welds")
          create(:competency, work_process: work_process_2, title: "Fit panels")
          create(:related_instruction, occupation_standard: time_standard, title: "Blueprint Reading", description: nil, hours: 40)
          create(:related_instruction, occupation_standard: time_standard, title: "Safety", description: nil, hours: 60, sort_order: 2)
          data_import = create(:data_import, occupation_standard: time_standard, user: manual_converter)
          create(
            :open_ai_import,
            import: data_import.import,
            occupation_standard: create(:occupation_standard, source: :ai_conversion),
            parsed_response: {
              "workProcesses" => [
                {"title" => "Cut Metal", "maximumHours" => 90, "competencies" => [{"title" => "Inspect welds"}]},
                {"title" => "Weld Frame", "maximumHours" => 200, "competencies" => []}
              ],
              "relatedInstructions" => [
                {"title" => "Blueprint Reading", "hours" => 50}
              ]
            }
          )

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

          create(:occupation_standard, sample_set: false, source: :rapids_api)
          create(:occupation_standard, sample_set: true, source: :ai_conversion)

          sign_in admin
          get sample_set_report_admin_occupation_standards_path(format: :csv, search: "source:rapids_api")

          csv = CSV.parse(response.body, headers: true)

          expect(response).to be_successful
          expect(response.media_type).to eq "text/csv"
          expect(csv.headers).to include(
            "agency_type",
            "import_user",
            "converted_at",
            "manual_wp_count",
            "ai_wp_count",
            "score_wp_text"
          )
          expect(csv.headers).not_to include(
            "report_total",
            "filters",
            "has_onet",
            "has_rapids",
            "manual_converter",
            "manual_converted_at"
          )
          expect(csv.count).to eq 2

          row = csv.find { |csv_row| csv_row["id"] == time_standard.id }

          expect(row["title"]).to eq time_standard.title
          expect(row["state_registered"]).to eq "true"
          expect(row["agency_type"]).to eq "oa"
          expect(row["ojt_type"]).to eq "time"
          expect(row["source"]).to eq "rapids_api"
          expect(row["organization"]).to eq organization.title
          expect(row["has_org"]).to eq "true"
          expect(row["import_user"]).to eq "converter@example.com"
          expect(row["converted_at"]).to be_present
          expect(row["manual_wp_count"]).to eq "2"
          expect(row["manual_skill_count"]).to eq "2"
          expect(row["manual_ojt_hours"]).to eq "300"
          expect(row["manual_ri_count"]).to eq "2"
          expect(row["manual_ri_hours"]).to eq "100"
          expect(row["ai_wp_count"]).to eq "2"
          expect(row["ai_skill_count"]).to eq "1"
          expect(row["ai_ojt_hours"]).to eq "290"
          expect(row["ai_ri_count"]).to eq "1"
          expect(row["ai_ri_hours"]).to eq "50"
          expect(row["score_wp_count"]).to eq "100.0"
          expect(row["score_skill_count"]).to eq "50.0"
          expect(row["score_ojt_hours"]).to eq "96.67"
          expect(row["score_ri_count"]).to eq "50.0"
          expect(row["score_ri_hours"]).to eq "50.0"
          expect(row["score_wp_text"]).to eq "100.0"
          expect(row["score_skill_text"]).to eq "50.0"
          expect(row["score_ri_text"]).to eq "66.67"

          empty_row = csv.find { |csv_row| csv_row["id"] == hybrid_standard.id }

          expect(empty_row["score_wp_count"]).to eq "N/A"
          expect(empty_row["score_skill_count"]).to eq "N/A"
          expect(empty_row["score_ojt_hours"]).to eq "N/A"
          expect(empty_row["score_ri_count"]).to eq "N/A"
          expect(empty_row["score_ri_hours"]).to eq "N/A"
          expect(empty_row["score_wp_text"]).to eq "N/A"
          expect(empty_row["score_ri_text"]).to eq "N/A"
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
