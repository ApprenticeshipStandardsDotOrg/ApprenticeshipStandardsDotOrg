require "rails_helper"

RSpec.describe "ContactRequest", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get contact_page_path

      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid params and decent Google recaptcha score" do
      it "creates a contact_request record" do
        stub_recaptcha_high_score

        expect {
          post contact_requests_path, params: {
            contact_request: {
              name: "Mickey",
              email: "mickey@mouse.com",
              organization: "Disney",
              message: "We are happy"
            }
          }
        }.to change(ContactRequest, :count).by(1)

        contact = ContactRequest.last
        expect(contact.name).to eq "Mickey"
        expect(contact.email).to eq "mickey@mouse.com"
        expect(contact.organization).to eq "Disney"
        expect(contact.message).to eq "We are happy"
        expect(response).to redirect_to guest_root_path
      end
    end

    context "with valid params and ENABLE_RECAPTCHA flag false" do
      it "creates a contact_request record" do
        stub_const "ENV", ENV.to_h.merge("ENABLE_RECAPTCHA" => "false")

        expect {
          post contact_requests_path, params: {
            contact_request: {
              name: "Mickey",
              email: "mickey@mouse.com",
              organization: "Disney",
              message: "We are happy"
            }
          }
        }.to change(ContactRequest, :count).by(1)

        contact = ContactRequest.last
        expect(contact.name).to eq "Mickey"
        expect(contact.email).to eq "mickey@mouse.com"
        expect(contact.organization).to eq "Disney"
        expect(contact.message).to eq "We are happy"
        expect(response).to redirect_to guest_root_path
      end
    end

    context "with valid params and no ENABLE_RECAPTCHA flag" do
      it "creates a contact_request record" do
        expect {
          post contact_requests_path, params: {
            contact_request: {
              name: "Mickey",
              email: "mickey@mouse.com",
              organization: "Disney",
              message: "We are happy"
            }
          }
        }.to change(ContactRequest, :count).by(1)

        contact = ContactRequest.last
        expect(contact.name).to eq "Mickey"
        expect(contact.email).to eq "mickey@mouse.com"
        expect(contact.organization).to eq "Disney"
        expect(contact.message).to eq "We are happy"
        expect(response).to redirect_to guest_root_path
      end
    end

    context "with valid params and poor Google recaptcha score" do
      it "does not create a contact_request record" do
        stub_recaptcha_low_score

        expect {
          post contact_requests_path, params: {
            "g-captcha-response": "foobar",
            contact_request: {
              name: "Mickey",
              email: "mickey@mouse.com",
              organization: "Disney",
              message: "We are happy"
            }
          }
        }.to_not change(ContactRequest, :count)

        expect(response).to redirect_to guest_root_path
      end
    end

    context "with valid params and unsuccessful recaptcha score" do
      it "does not create a contact_request record and reports error" do
        stub_recaptcha_failure

        expect_any_instance_of(ErrorSubscriber).to receive(:report).and_call_original
        expect {
          post contact_requests_path, params: {
            "g-captcha-response": "foobar",
            contact_request: {
              name: "Mickey",
              email: "mickey@mouse.com",
              organization: "Disney",
              message: "We are happy"
            }
          }
        }.to_not change(ContactRequest, :count)

        expect(response).to redirect_to guest_root_path
      end
    end

    context "with invalid params" do
      it "does not creates a contact_request record" do
        stub_recaptcha_high_score

        expect {
          post contact_requests_path, params: {
            "g-captcha-response": "foobar",
            contact_request: {
              name: "Mickey",
              email: "",
              organization: "Disney",
              message: "We are happy"
            }
          }
        }.to_not change(ContactRequest, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
