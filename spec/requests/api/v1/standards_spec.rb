require "swagger_helper"

RSpec.describe "api/v1/standards", type: :request do
  path "/api/v1/standards" do
    get "List standards" do
      parameter name: :"filter[title]", in: :query, type: :string, required: false, description: "Filter by title"
      parameter name: :"filter[onet_code]", in: :query, type: :string, required: false, description: "Filter by ONET code"
      parameter name: :"filter[rapids_code]", in: :query, type: :string, required: false, description: "Filter by RAPIDS code"
      parameter(
        name: :Authorization,
        in: :header,
        type: :string,
        required: true,
        description: "Bearer token"
      )
      security [bearer: []]
      produces "application/vnd.api+json"

      let(:user) { create(:user) }
      let(:token) { user.create_api_access_token!.jwt_token }
      let(:Authorization) { "Bearer #{token}" }
      let(:registration_agency) { create(:registration_agency, agency_type: :saa, for_state_abbreviation: "CA") }
      let!(:standard1) {
        create(
          :occupation_standard,
          registration_agency: registration_agency,
          organization: build(:organization, title: "HR Industries, Inc"),
          title: "Human Resource Specialist",
          existing_title: "Career Development Technician",
          term_months: 12,
          ojt_type: :time,
          probationary_period_months: 6,
          onet_code: "51-7011.00",
          rapids_code: "0857",
          apprenticeship_to_journeyworker_ratio: "5:1",
          ojt_hours_min: 100,
          ojt_hours_max: 150,
          rsi_hours_min: 300,
          rsi_hours_max: 350
        )
      }
      let!(:standard2) {
        create(
          :occupation_standard,
          registration_agency: registration_agency,
          title: "Automotive Technician Specialist",
          existing_title: nil,
          term_months: 24,
          ojt_type: :competency,
          probationary_period_months: 12,
          onet_code: "49-3023.02",
          rapids_code: "1034",
          apprenticeship_to_journeyworker_ratio: "1:1",
          ojt_hours_min: 1000,
          ojt_hours_max: 1500,
          rsi_hours_min: 200,
          rsi_hours_max: 250
        )
      }
      let!(:onet3) { create(:onet, code: "49-3023.02") }
      let!(:occupation3) { create(:occupation, onet: onet3, rapids_code: "0857") }
      let!(:standard3) {
        create(
          :occupation_standard,
          occupation: occupation3,
          registration_agency: registration_agency,
          title: "Welder",
          existing_title: nil,
          term_months: 36,
          ojt_type: :hybrid,
          probationary_period_months: 24,
          onet_code: "49-3023.02",
          rapids_code: "0857",
          apprenticeship_to_journeyworker_ratio: "1:2",
          ojt_hours_min: 3000,
          ojt_hours_max: 3500,
          rsi_hours_min: 400,
          rsi_hours_max: 450
        )
      }
      let!(:onet4) { create(:onet, code: "51-4121.06") }
      let!(:occupation4) { create(:occupation, onet: onet4, rapids_code: "1234") }
      let!(:standard4) {
        create(
          :occupation_standard,
          occupation: occupation4,
          registration_agency: registration_agency,
          title: "Ship Engineers",
          existing_title: nil,
          term_months: 36,
          ojt_type: :hybrid,
          probationary_period_months: 24,
          onet_code: "51-4121.06",
          rapids_code: "1234",
          apprenticeship_to_journeyworker_ratio: "1:2",
          ojt_hours_min: 3000,
          ojt_hours_max: 3500,
          rsi_hours_min: 400,
          rsi_hours_max: 450
        )
      }

      response(200, "successful") do
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
                      existing_title: {type: :string, nullable: true},
                      sponsor_name: {type: :string, nullable: true},
                      registration_agency: {type: :string},
                      onet_code: {type: :string, nullable: true},
                      rapids_code: {type: :string, nullable: true},
                      ojt_type: {type: :string},
                      term_months: {type: :integer, nullable: true},
                      probationary_period_months: {type: :integer, nullable: true},
                      apprenticeship_to_journeyworker_ratio: {type: :string, nullable: true},
                      ojt_hours_min: {
                        type: :integer,
                        nullable: true,
                        description: "Minimum on the job hours required"
                      },
                      ojt_hours_max: {
                        type: :integer,
                        nullable: true,
                        description: "Maximum on the job hours required"
                      },
                      rsi_hours_min: {
                        type: :integer,
                        nullable: true,
                        description: "Minimum related instruction hours required"
                      },
                      rsi_hours_max: {
                        type: :integer,
                        nullable: true,
                        description: "Maximum related instruction hours required"
                      }
                    },
                    required: %w[title registration_agency]
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
                id: standard2.id.to_s,
                type: "standards",
                links: {
                  self: api_v1_standard_url(standard2)
                },
                attributes: {
                  title: "Automotive Technician Specialist",
                  existing_title: nil,
                  sponsor_name: nil,
                  registration_agency: "California (SAA)",
                  onet_code: "49-3023.02",
                  rapids_code: "1034",
                  ojt_type: "competency_based",
                  term_months: 24,
                  probationary_period_months: 12,
                  apprenticeship_to_journeyworker_ratio: "1:1",
                  ojt_hours_min: 1000,
                  ojt_hours_max: 1500,
                  rsi_hours_min: 200,
                  rsi_hours_max: 250
                }
              },
              {
                id: standard1.id.to_s,
                type: "standards",
                links: {
                  self: api_v1_standard_url(standard1)
                },
                attributes: {
                  title: "Human Resource Specialist",
                  existing_title: "Career Development Technician",
                  sponsor_name: "HR Industries, Inc",
                  registration_agency: "California (SAA)",
                  onet_code: "51-7011.00",
                  rapids_code: "0857",
                  ojt_type: "time_based",
                  term_months: 12,
                  probationary_period_months: 6,
                  apprenticeship_to_journeyworker_ratio: "5:1",
                  ojt_hours_min: 100,
                  ojt_hours_max: 150,
                  rsi_hours_min: 300,
                  rsi_hours_max: 350
                }
              },
              {
                id: standard4.id.to_s,
                type: "standards",
                links: {
                  self: api_v1_standard_url(standard4)
                },
                attributes: {
                  title: "Ship Engineers",
                  existing_title: nil,
                  sponsor_name: nil,
                  registration_agency: "California (SAA)",
                  onet_code: "51-4121.06",
                  rapids_code: "1234",
                  ojt_type: "hybrid_based",
                  term_months: 36,
                  probationary_period_months: 24,
                  apprenticeship_to_journeyworker_ratio: "1:2",
                  ojt_hours_min: 3000,
                  ojt_hours_max: 3500,
                  rsi_hours_min: 400,
                  rsi_hours_max: 450
                }
              },
              {
                id: standard3.id.to_s,
                type: "standards",
                links: {
                  self: api_v1_standard_url(standard3)
                },
                attributes: {
                  title: "Welder",
                  existing_title: nil,
                  sponsor_name: nil,
                  registration_agency: "California (SAA)",
                  onet_code: "49-3023.02",
                  rapids_code: "0857",
                  ojt_type: "hybrid_based",
                  term_months: 36,
                  probationary_period_months: 24,
                  apprenticeship_to_journeyworker_ratio: "1:2",
                  ojt_hours_min: 3000,
                  ojt_hours_max: 3500,
                  rsi_hours_min: 400,
                  rsi_hours_max: 450
                }
              }
            ]
          }

          expect(response_json).to eq expected_resp
        end
      end

      context "filter by title" do
        response(200, "success", document: false) do
          let("filter[title]") { "Human Resource Specialist" }

          run_test! do |response|
            expected_resp = {
              data: [
                {
                  id: standard1.id.to_s,
                  type: "standards",
                  links: {
                    self: api_v1_standard_url(standard1)
                  },
                  attributes: {
                    title: "Human Resource Specialist",
                    existing_title: "Career Development Technician",
                    sponsor_name: "HR Industries, Inc",
                    registration_agency: "California (SAA)",
                    onet_code: "51-7011.00",
                    rapids_code: "0857",
                    ojt_type: "time_based",
                    term_months: 12,
                    probationary_period_months: 6,
                    apprenticeship_to_journeyworker_ratio: "5:1",
                    ojt_hours_min: 100,
                    ojt_hours_max: 150,
                    rsi_hours_min: 300,
                    rsi_hours_max: 350
                  }
                }
              ]
            }

            expect(response_json).to eq expected_resp
          end
        end
      end

      context "filter by onet_code" do
        response(200, "success", document: false) do
          let("filter[onet_code]") { "49-3023.02" }

          run_test! do |response|
            expected_resp = {
              data: [
                {
                  id: standard2.id.to_s,
                  type: "standards",
                  links: {
                    self: api_v1_standard_url(standard2)
                  },
                  attributes: {
                    title: "Automotive Technician Specialist",
                    existing_title: nil,
                    sponsor_name: nil,
                    registration_agency: "California (SAA)",
                    onet_code: "49-3023.02",
                    rapids_code: "1034",
                    ojt_type: "competency_based",
                    term_months: 24,
                    probationary_period_months: 12,
                    apprenticeship_to_journeyworker_ratio: "1:1",
                    ojt_hours_min: 1000,
                    ojt_hours_max: 1500,
                    rsi_hours_min: 200,
                    rsi_hours_max: 250
                  }
                },
                {
                  id: standard3.id.to_s,
                  type: "standards",
                  links: {
                    self: api_v1_standard_url(standard3)
                  },
                  attributes: {
                    title: "Welder",
                    existing_title: nil,
                    sponsor_name: nil,
                    registration_agency: "California (SAA)",
                    onet_code: "49-3023.02",
                    rapids_code: "0857",
                    ojt_type: "hybrid_based",
                    term_months: 36,
                    probationary_period_months: 24,
                    apprenticeship_to_journeyworker_ratio: "1:2",
                    ojt_hours_min: 3000,
                    ojt_hours_max: 3500,
                    rsi_hours_min: 400,
                    rsi_hours_max: 450
                  }
                }
              ]
            }

            expect(response_json).to eq expected_resp
          end
        end
      end

      context "filter by rapids_code" do
        response(200, "success", document: false) do
          let("filter[rapids_code]") { "0857" }

          run_test! do |response|
            expected_resp = {
              data: [
                {
                  id: standard1.id.to_s,
                  type: "standards",
                  links: {
                    self: api_v1_standard_url(standard1)
                  },
                  attributes: {
                    title: "Human Resource Specialist",
                    existing_title: "Career Development Technician",
                    sponsor_name: "HR Industries, Inc",
                    registration_agency: "California (SAA)",
                    onet_code: "51-7011.00",
                    rapids_code: "0857",
                    ojt_type: "time_based",
                    term_months: 12,
                    probationary_period_months: 6,
                    apprenticeship_to_journeyworker_ratio: "5:1",
                    ojt_hours_min: 100,
                    ojt_hours_max: 150,
                    rsi_hours_min: 300,
                    rsi_hours_max: 350
                  }
                },
                {
                  id: standard3.id.to_s,
                  type: "standards",
                  links: {
                    self: api_v1_standard_url(standard3)
                  },
                  attributes: {
                    title: "Welder",
                    existing_title: nil,
                    sponsor_name: nil,
                    registration_agency: "California (SAA)",
                    onet_code: "49-3023.02",
                    rapids_code: "0857",
                    ojt_type: "hybrid_based",
                    term_months: 36,
                    probationary_period_months: 24,
                    apprenticeship_to_journeyworker_ratio: "1:2",
                    ojt_hours_min: 3000,
                    ojt_hours_max: 3500,
                    rsi_hours_min: 400,
                    rsi_hours_max: 450
                  }
                }
              ]
            }

            expect(response_json).to eq expected_resp
          end
        end
      end

      response(401, "unauthorized") do
        let(:Authorization) { "Bearer badtoken" }
        run_test!
      end
    end
  end

  path "/api/v1/standards/{id}" do
    get "Retrieve standard" do
      parameter name: :id, in: :path, type: :string
      parameter(
        name: :Authorization,
        in: :header,
        type: :string,
        required: true,
        description: "Bearer token"
      )
      security [bearer: []]
      produces "application/vnd.api+json"

      response(200, "successful") do
        let(:user) { create(:user) }
        let(:token) { user.create_api_access_token!.jwt_token }
        let(:Authorization) { "Bearer #{token}" }
        let(:registration_agency) { create(:registration_agency, agency_type: :saa, for_state_abbreviation: "CA") }
        let!(:standard) {
          create(
            :occupation_standard,
            registration_agency: registration_agency,
            organization: build(:organization, title: "HR Industries, Inc"),
            title: "Human Resource Specialist",
            existing_title: "Career Development Technician",
            term_months: 12,
            ojt_type: :time,
            probationary_period_months: 6,
            onet_code: "51-7011.00",
            rapids_code: "0857",
            apprenticeship_to_journeyworker_ratio: "5:1",
            ojt_hours_min: 100,
            ojt_hours_max: 150,
            rsi_hours_min: 300,
            rsi_hours_max: 350
          )
        }
        let(:id) { standard.id }

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
                    existing_title: {type: :string, nullable: true},
                    sponsor_name: {type: :string, nullable: true},
                    registration_agency: {type: :string},
                    onet_code: {type: :string, nullable: true},
                    rapids_code: {type: :string, nullable: true},
                    ojt_type: {type: :string},
                    term_months: {type: :integer, nullable: true},
                    probationary_period_months: {type: :integer, nullable: true},
                    apprenticeship_to_journeyworker_ratio: {type: :string, nullable: true},
                    ojt_hours_min: {
                      type: :integer,
                      nullable: true,
                      description: "Minimum on the job hours required"
                    },
                    ojt_hours_max: {
                      type: :integer,
                      nullable: true,
                      description: "Maximum on the job hours required"
                    },
                    rsi_hours_min: {
                      type: :integer,
                      nullable: true,
                      description: "Minimum related instruction hours required"
                    },
                    rsi_hours_max: {
                      type: :integer,
                      nullable: true,
                      description: "Maximum related instruction hours required"
                    }
                  },
                  required: %w[title registration_agency]
                }
              },
              required: %w[id type attributes links]
            }
          },
          required: %w[data]

        run_test! do |response|
          expected_resp = {
            data: {
              id: standard.id.to_s,
              type: "standards",
              links: {
                self: api_v1_standard_url(standard)
              },
              attributes: {
                title: "Human Resource Specialist",
                existing_title: "Career Development Technician",
                sponsor_name: "HR Industries, Inc",
                registration_agency: "California (SAA)",
                onet_code: "51-7011.00",
                rapids_code: "0857",
                ojt_type: "time_based",
                term_months: 12,
                probationary_period_months: 6,
                apprenticeship_to_journeyworker_ratio: "5:1",
                ojt_hours_min: 100,
                ojt_hours_max: 150,
                rsi_hours_min: 300,
                rsi_hours_max: 350
              }
            }
          }

          expect(response_json).to eq expected_resp
        end
      end

      response(401, "unauthorized") do
        let(:Authorization) { "Bearer badtoken" }
        let!(:standard) { create(:occupation_standard) }
        let(:id) { standard.id }
        run_test!
      end
    end
  end
end
