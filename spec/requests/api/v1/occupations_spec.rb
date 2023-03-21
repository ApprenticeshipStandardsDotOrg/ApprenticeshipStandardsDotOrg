require "swagger_helper"

RSpec.describe "api/v1/occupations", type: :request do
  path "/api/v1/occupations" do
    get "List occupations" do
      produces "application/vnd.api+json"

      response(200, "successful") do
        let(:onet1) { create(:onet, code: "51-7011.00") }
        let!(:occ1) { create(:occupation, title: "Information Technology Specialist", onet: onet1, rapids_code: "1132", time_based_hours: 2782, competency_based_hours: 2000) }
        let!(:occ2) { create(:occupation, title: "Accordion Maker", rapids_code: "0860", time_based_hours: 8000, competency_based_hours: 8500) }

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
                  links: {
                    type: :object,
                    properties: {
                      self: {type: :string}
                    },
                    required: %w[self]
                  },
                  attributes: {
                    type: :object,
                    properties: {
                      title: {type: :string},
                      onet_code: {type: :string, nullable: true},
                      rapids_code: {type: :string, nullable: true},
                      time_based_hours: {type: :integer, nullable: true},
                      competency_based_hours: {type: :integer, nullable: true}
                    },
                    required: %w[title]
                  }
                },
                required: %w[id type attributes links]
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
                  title: occ2.title,
                  onet_code: nil,
                  rapids_code: "0860",
                  time_based_hours: 8000,
                  competency_based_hours: 8500
                }
              },
              {
                id: occ1.id.to_s,
                type: "occupations",
                links: {
                  self: api_v1_occupation_url(occ1)
                },
                attributes: {
                  title: occ1.title,
                  onet_code: "51-7011.00",
                  rapids_code: "1132",
                  time_based_hours: 2782,
                  competency_based_hours: 2000
                }
              }
            ]
          }

          expect(response_json).to eq expected_resp
        end
      end
    end
  end

  path "/api/v1/occupations/{id}" do
    get "Retrieve occupation" do
      parameter name: :id, in: :path, type: :string
      produces "application/vnd.api+json"

      response(200, "successful") do
        let(:onet1) { create(:onet, code: "51-7011.00") }
        let!(:occ) { create(:occupation, title: "Information Technology Specialist", onet: onet1, rapids_code: "1132", time_based_hours: 2782, competency_based_hours: 2000) }
        let(:id) { occ.id }

        after do |example|
          example.metadata[:response][:content] = {
            "application/vnd.api+json" => {example: response_json}
          }
        end

        schema type: :object,
          properties: {
            data: {
              type: :object,
              properties: {
                id: {type: :string},
                type: {type: :string},
                links: {
                  type: :object,
                  properties: {
                    self: {type: :string}
                  },
                  required: %w[self]
                },
                attributes: {
                  type: :object,
                  properties: {
                    title: {type: :string},
                    onet_code: {type: :string, nullable: true},
                    rapids_code: {type: :string, nullable: true},
                    time_based_hours: {type: :integer, nullable: true},
                    competency_based_hours: {type: :integer, nullable: true}
                  },
                  required: %w[title]
                },
                required: %w[id type attributes links]
              }
            }
          },
          required: %w[data]

        run_test! do |response|
          expected_resp = {
            data: {
              id: occ.id.to_s,
              type: "occupations",
              links: {
                self: api_v1_occupation_url(occ)
              },
              attributes: {
                title: occ.title,
                onet_code: "51-7011.00",
                rapids_code: "1132",
                time_based_hours: 2782,
                competency_based_hours: 2000
              }
            }
          }

          expect(response_json).to eq expected_resp
        end
      end
    end
  end
end
