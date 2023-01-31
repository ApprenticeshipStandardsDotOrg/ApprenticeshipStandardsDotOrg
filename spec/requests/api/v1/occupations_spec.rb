require "swagger_helper"

RSpec.describe "api/v1/occupations", type: :request do
  path "/api/v1/occupations" do
    get "List occupations" do
      response(200, "successful") do
        produces "application/vnd.api+json"

        let(:onet_code1) { create(:onet_code, code: "123.4") }
        let!(:occ1) { create(:occupation, name: "Foo", description: "Occ1 Desc", onet_code: onet_code1, time_based_hours: 400) }
        let!(:occ2) { create(:occupation, name: "Bar", description: "Occ2 Desc", rapids_code: "4567", competency_based_hours: 250) }

        after do |example|
          example.metadata[:response][:content] = {
            "application/vnd.api+json" => {example: response_json}
          }
        end

        schema type: :object,
          properties: {
            data: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: {type: :string},
                  type: {type: :string},
                  attributes: {
                    type: :object,
                    properties: {
                      name: {type: :string},
                      description: {type: :string, nullable: true},
                      onet_code: {type: :string, nullable: true},
                      rapids_code: {type: :string, nullable: true},
                      time_based_hours: {type: :integer, nullable: true},
                      competency_based_hours: {type: :integer, nullable: true}
                    },
                    required: %w[name]
                  }
                },
                required: %w[id type attributes]
              }
            }
          },
          required: %w[data]

        run_test! do |response|
          expected_resp = {
            data: [
              {
                id: occ2.id.to_s,
                type: "occupations",
                links: {
                  self: api_v1_occupation_url(occ2)
                },
                attributes: {
                  name: occ2.name,
                  description: occ2.description,
                  onet_code: nil,
                  rapids_code: "4567",
                  time_based_hours: nil,
                  competency_based_hours: 250
                }
              },
              {
                id: occ1.id.to_s,
                type: "occupations",
                links: {
                  self: api_v1_occupation_url(occ1)
                },
                attributes: {
                  name: occ1.name,
                  description: occ1.description,
                  onet_code: "123.4",
                  rapids_code: nil,
                  time_based_hours: 400,
                  competency_based_hours: nil
                }
              }
            ]
          }

          expect(json_response).to eq expected_resp
        end
      end
    end
  end
end
