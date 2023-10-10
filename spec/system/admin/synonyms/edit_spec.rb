require "rails_helper"
require "elasticsearch_wrapper/synonyms"

RSpec.describe "admin/synonyms/edit" do
  it "allows admin user to edit synonym", :admin do
    synonym = create(:synonym, word: "Software", synonyms: "Developer")
    admin = create(:admin)

    login_as admin
    visit edit_admin_synonym_path(synonym)

    expect(page).to have_selector("h1", text: "Edit Synonyms for Software")
    expect(page).to have_field("Word")
    expect(page).to have_field("Synonyms")

    fill_in "Word", with: "Software Engineer"
    fill_in "Synonyms", with: "Developer, Dev"

    expect(ElasticsearchWrapper::Synonyms).to receive(:add).with(
      rule_id: synonym.id,
      value: "Software Engineer,Developer, Dev"
    )
    click_on "Update Synonym"

    within("h1") do
      expect(page).to have_content("Synonyms for Software Engineer")
    end

    expect(page).to have_content "Software Engineer"
    expect(page).to have_content "Developer, Dev"
  end
end
