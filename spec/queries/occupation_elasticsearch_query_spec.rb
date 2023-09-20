require "rails_helper"

RSpec.describe OccupationElasticsearchQuery, :elasticsearch do
  it "allows typeahead searching of occupation by title" do
    o1 = create(:occupation, title: "Software Developer")
    o2 = create(:occupation, title: "Software Engineer")
    create(:occupation, title: "Microsoft Specialist")

    Occupation.import
    Occupation.__elasticsearch__.refresh_index!

    params = {q: "soft"}
    response = described_class.new(search_params: params).call

    expect(response.records.pluck(:id)).to contain_exactly(o1.id, o2.id)

    params = {q: "develop"}
    response = described_class.new(search_params: params).call

    expect(response.records.pluck(:id)).to contain_exactly(o1.id)
  end

  it "allows typeahead searching of occupations by rapids code" do
    o1 = create(:occupation, rapids_code: "1234")
    o2 = create(:occupation, rapids_code: "1234cB")
    create(:occupation, rapids_code: "123")

    Occupation.import
    Occupation.__elasticsearch__.refresh_index!

    params = {q: "1234"}
    response = described_class.new(search_params: params).call

    expect(response.records.pluck(:id)).to contain_exactly(o1.id, o2.id)

    params = {q: "1234Cb"}
    response = described_class.new(search_params: params).call

    expect(response.records.pluck(:id)).to contain_exactly(o2.id)
  end

  it "allows typeahead searching of occupations by onet code" do
    onet1 = create(:onet, code: "12.3456")
    onet2 = create(:onet, code: "12.3457")
    onet3 = create(:onet, code: "11.2345")

    o1 = create(:occupation, onet: onet1)
    create(:occupation, onet: onet2)
    create(:occupation, onet: onet3)

    Occupation.import
    Occupation.__elasticsearch__.refresh_index!

    params = {q: "12.3456"}
    response = described_class.new(search_params: params).call

    expect(response.records.pluck(:id)).to contain_exactly(o1.id)
  end
end
