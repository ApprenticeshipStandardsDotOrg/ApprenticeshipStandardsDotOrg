require "rails_helper"

RSpec.describe "admin/open_ai_prompts/edit", :admin do
  it "shows default status and lets an admin set the prompt as default" do
    admin = create(:admin)
    previous_default = create(:open_ai_prompt, name: "Previous prompt", default: true)
    prompt = create(:open_ai_prompt, name: "New prompt", prompt: "Updated prompt")

    login_as admin
    visit edit_admin_open_ai_prompt_path(prompt)

    expect(page).to have_text "This prompt is not currently used by Convert with AI."
    expect(page).to have_link "Previous prompt", href: edit_admin_open_ai_prompt_path(previous_default)
    expect(page).to have_button "Save and set as default"
    expect(page).to have_no_text "Show Default OpenAI Prompt"

    fill_in "Prompt", with: "Updated prompt text"
    click_on "Save and set as default"

    expect(page).to have_text "Open AI prompt was successfully updated."
    expect(prompt.reload).to be_default
    expect(prompt.prompt).to eq "Updated prompt text"
    expect(previous_default.reload).not_to be_default
  end

  it "makes the current default obvious" do
    admin = create(:admin)
    prompt = create(:open_ai_prompt, default: true)

    login_as admin
    visit edit_admin_open_ai_prompt_path(prompt)

    expect(page).to have_text "This prompt is currently used by Convert with AI."
    expect(page).to have_no_button "Save and set as default"
  end
end
