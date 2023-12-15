require "rails_helper"

RSpec.describe "OccupationStandard", type: :request do
  describe "GET /index" do
    context "when guest" do
      context "without ES search" do
        it "returns http success" do
          create_pair(:occupation_standard, :with_work_processes, :with_data_import)

          get occupation_standards_path

          expect(response).to be_successful
        end
      end

      context "with ES search", :elasticsearch do
        it "makes one Elasticsearch query if no search params" do
          Flipper.enable :use_elasticsearch_for_search
          create(:occupation_standard, :with_work_processes, :with_data_import)

          expect(OccupationStandardElasticsearchQuery).to receive(:new).once.and_call_original
          get occupation_standards_path

          expect(response).to be_successful
          Flipper.disable :use_elasticsearch_for_search
        end

        it "makes one Elasticsearch query if only filter params" do
          Flipper.enable :use_elasticsearch_for_search
          state = create(:state)
          ra = create(:registration_agency, state: state)
          create(:occupation_standard, :with_work_processes, :with_data_import, registration_agency: ra)

          expect(OccupationStandardElasticsearchQuery).to receive(:new).once.and_call_original
          get occupation_standards_path(state_id: state.id)

          expect(response).to be_successful
          Flipper.disable :use_elasticsearch_for_search
        end

        it "makes one Elasticsearch query if search params does not start with letter" do
          Flipper.enable :use_elasticsearch_for_search
          create(:occupation_standard, :with_work_processes, :with_data_import, title: "Mechanic", onet_code: "15-1234.00")

          expect(OccupationStandardElasticsearchQuery).to receive(:new).once.and_call_original
          get occupation_standards_path(q: "15")

          expect(response).to be_successful
          Flipper.disable :use_elasticsearch_for_search
        end

        it "makes two Elasticsearch queries if search params start with letter" do
          Flipper.enable :use_elasticsearch_for_search
          create(:occupation_standard, :with_work_processes, :with_data_import, title: "Mechanic")

          expect(OccupationStandardElasticsearchQuery).to receive(:new).twice.and_call_original
          get occupation_standards_path(q: "Mechanic")

          expect(response).to be_successful
          Flipper.disable :use_elasticsearch_for_search
        end

        it "makes one Elasticsearch query if search params start with letter but onet_prefix is included in the search params" do
          Flipper.enable :use_elasticsearch_for_search
          create(:occupation_standard, :with_work_processes, :with_data_import, title: "Mechanic")

          expect(OccupationStandardElasticsearchQuery).to receive(:new).once.and_call_original
          get occupation_standards_path(q: "Mechanic", onet_prefix: "15-1234")

          expect(response).to be_successful
          Flipper.disable :use_elasticsearch_for_search
        end

        it "does not include onet_prefix in 2nd query if first hit has no onet code" do
          Flipper.enable :use_elasticsearch_for_search
          create(:occupation_standard, :with_work_processes, :with_data_import, onet_code: nil, title: "Mechanic")

          search_params = ActionController::Parameters.new({q: "Mechanic"}).permit!
          expect(OccupationStandardElasticsearchQuery).to receive(:new).with(search_params: search_params).once.and_call_original
          expect(OccupationStandardElasticsearchQuery).to receive(:new).with(search_params: search_params, offset: 0).once.and_call_original
          get occupation_standards_path(q: "Mechanic")

          expect(response).to be_successful
          Flipper.disable :use_elasticsearch_for_search
        end

        it "does not have any N+1 queries" do
          Flipper.enable :use_elasticsearch_for_search

          org = create(:organization)
          os = create(:occupation_standard, :with_work_processes, :with_data_import, organization: org)
          new_wp = build(:work_process, title: os.work_processes.first.title)
          create(:occupation_standard, :with_data_import, work_processes: [new_wp], organization: org)
          create(:occupation_standard, :with_work_processes, :with_data_import, organization: org)

          OccupationStandard.import
          OccupationStandard.__elasticsearch__.refresh_index!

          get occupation_standards_path

          expect(response).to be_successful
          Flipper.disable :use_elasticsearch_for_search
        end
      end
    end

    context "on staging" do
      it "returns unauthorized if no http basic auth credentials" do
        stub_const "ENV", ENV.to_h.merge("APP_ENVIRONMENT" => "staging", "BASIC_AUTH_USERNAME" => "admin", "BASIC_AUTH_PASSWORD" => "password")

        get occupation_standards_path

        expect(response).to be_unauthorized
      end

      it "returns unauthorized if incorrect http basic auth credentials passed" do
        stub_const "ENV", ENV.to_h.merge("APP_ENVIRONMENT" => "staging", "BASIC_AUTH_USERNAME" => "admin", "BASIC_AUTH_PASSWORD" => "password")
        authorization = ActionController::HttpAuthentication::Basic.encode_credentials("admin", "badpassword")

        get occupation_standards_path, headers: {"HTTP_AUTHORIZATION" => authorization}

        expect(response).to be_unauthorized
      end

      it "is successful if correct http basic auth credentials passed" do
        stub_const "ENV", ENV.to_h.merge("APP_ENVIRONMENT" => "staging", "BASIC_AUTH_USERNAME" => "admin", "BASIC_AUTH_PASSWORD" => "password")
        authorization = ActionController::HttpAuthentication::Basic.encode_credentials("admin", "password")

        get occupation_standards_path, headers: {"HTTP_AUTHORIZATION" => authorization}

        expect(response).to be_successful
      end
    end
  end

  describe "GET /show/:id" do
    context "when guest" do
      it "returns http success" do
        occupation_standard = create(:occupation_standard, :with_data_import)

        get occupation_standard_path(occupation_standard)

        expect(response).to be_successful
      end
    end
  end

  describe "GET /show/:id.docx" do
    it "returns a docx document" do
      occupation_standard = create(:occupation_standard, :with_data_import)

      get occupation_standard_path(occupation_standard), params: {format: "docx"}

      docx_mime_type = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"

      expect(response).to be_successful
      expect(response.content_type).to eq docx_mime_type
    end
  end
end
