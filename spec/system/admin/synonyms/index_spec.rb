require "rails_helper"

RSpec.describe "admin/synonyms/index", :admin do
  it "can search by word" do
    create(:synonym, word: "UX", synonyms: "User Experience")
    create(:synonym, word: "Software Engineer", synonyms: "Dev, Developer")

    admin = create(:admin)

    login_as admin
    visit admin_synonyms_path

    expect(page).to have_gridcell("UX")
    expect(page).to have_gridcell("Software Engineer")

    visit admin_synonyms_path(search: "Software")

    expect(page).to have_gridcell("Software Engineer")
    expect(page).to_not have_gridcell("UX")
  end

  it "can search by synonym" do
    create(:synonym, word: "UX", synonyms: "User Experience")
    create(:synonym, word: "Software Engineer", synonyms: "Dev, Developer")

    admin = create(:admin)

    login_as admin
    visit admin_synonyms_path

    expect(page).to have_gridcell("UX")
    expect(page).to have_gridcell("Software Engineer")

    visit admin_synonyms_path(search: "Dev")

    expect(page).to have_gridcell("Software Engineer")
    expect(page).to_not have_gridcell("UX")
  end
end
