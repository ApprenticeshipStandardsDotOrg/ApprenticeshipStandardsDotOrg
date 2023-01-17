require "rails_helper"

RSpec.describe "WorkProcesses", type: :request do
  describe "GET /index" do
    context "on admin subdomain", :admin do
      context "when admin user" do
        it "returns http success" do
          admin = create(:admin)
          create(:work_process)

          sign_in admin
          get new_work_process_path

          expect(response).to be_successful
        end
      end

      context "when guest" do
        it "redirects to root path" do
          get new_work_process_path

          expect(response).to redirect_to new_user_session_path
        end
      end
    end

    context "on non-admin subdomain" do
      it "has 404 response" do
        expect {
          get new_work_process_path
        }.to raise_error(ActionController::RoutingError)
      end
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates new work process and redirects to index page" do
        expect {
          post work_processes_path, params: {
            work_process: {
              title: "Brakes",
              description: "This is what you should do to count hours against brakes requirements",
              occupation_standard_id: 1, 
              default_hours: 100
            }
          }
        }.to change(WorkProcess, :count).by(1)

        wp = WorkProcess.last
        expect(wp.title).to eq "Brakes"
        expect(wp.description).to eq "This is what you should do to count hours against brakes requirements"
        expect(wp.occupation_standard_id).to eq 1
        expect(wp.default_hours).to eq 100

        expect(response).to redirect_to work_processes_path
      end
    end

    # context "with invalid parameters" do
    #   it "does not create new standards import record and renders new" do
    #     allow_any_instance_of(StandardsImport).to receive(:save).and_return(false)
    #     expect {
    #       post standards_imports_path, params: {
    #         standards_import: {
    #           name: "Mickey Mouse",
    #           email: "mickey@mouse.com",
    #           organization: "Disney",
    #           notes: "a" * 500
    #         }
    #       }
    #     }.to_not change(StandardsImport, :count)

    #     expect(response).to have_http_status(:ok)
    #   end
    # end
  end
end
