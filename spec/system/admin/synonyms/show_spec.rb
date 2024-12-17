require "rails_helper"

RSpec.describe "admin/synonyms/show" do
  it "displays word and synonyms", :admin do
    synonym = create(:synonym, word: "Software Engineer", synonyms: "Dev, Developer")

    admin = create(:admin)

    login_as admin
    visit admin_synonym_path(synonym)

    expect(page).to have_selector("h1", text: "Show Synonyms for Software Engineer")
    expect(page).to have_selector("dt", text: "Word")
    expect(page).to have_selector("dt", text: "Synonyms")

    expect(page).to have_selector("dd", text: synonym.word)
    expect(page).to have_selector("dd", text: synonym.synonyms)

    expect(page).to have_link("Edit Synonyms for Software Engineer", href: edit_admin_synonym_path(synonym))
    expect(page).to have_selector("form[action='#{admin_synonym_path(synonym)}'][method='post']")
    expect(page).to have_button("Destroy")
  end
end
