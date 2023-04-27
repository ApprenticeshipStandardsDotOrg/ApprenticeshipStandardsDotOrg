require "rails_helper"

RSpec.describe OccupationStandardQuery do
  it "allows filtering occupation standards by title" do
    occupation_standard_for_mechanic = create(:occupation_standard, title: "Mechanic")
    create(:occupation_standard, title: "Pipe Fitter")
    params = {search_term: "Mechanic"}

    occupation_standard_search = OccupationStandardQuery.run(
      OccupationStandard.all, params
    )

    expect(occupation_standard_search.pluck(:id)).to eq [occupation_standard_for_mechanic.id]
  end
end
