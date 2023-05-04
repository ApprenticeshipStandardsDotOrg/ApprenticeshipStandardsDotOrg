require "rails_helper"

RSpec.describe OccupationStandardQuery do
  it "allows filtering occupation standards by title" do
    occupation_standard_for_mechanic = create(:occupation_standard, title: "Mechanic")
    create(:occupation_standard, title: "Pipe Fitter")
    params = {q: "Mechanic"}

    occupation_standard_search = OccupationStandardQuery.run(
      OccupationStandard.all, params
    )

    expect(occupation_standard_search.pluck(:id)).to eq [occupation_standard_for_mechanic.id]
  end

  it "allows filtering occupation standards by rapids code" do
    os1 = create(:occupation_standard, rapids_code: "1234")
    os2 = create(:occupation_standard, rapids_code: "1234CB")
    create(:occupation_standard, title: "HR", rapids_code: "123")

    params = {q: "1234"}

    occupation_standard_search = OccupationStandardQuery.run(
      OccupationStandard.all, params
    )

    expect(occupation_standard_search.pluck(:id)).to contain_exactly(os1.id, os2.id)
  end

  it "allows filtering occupation standards by onet code" do
    os1 = create(:occupation_standard, onet_code: "12.3456")
    os2 = create(:occupation_standard, onet_code: "12.34567")
    create(:occupation_standard, title: "HR", onet_code: "12.3")

    params = {q: "12.3456"}

    occupation_standard_search = OccupationStandardQuery.run(
      OccupationStandard.all, params
    )

    expect(occupation_standard_search.pluck(:id)).to contain_exactly(os1.id, os2.id)
  end
end
