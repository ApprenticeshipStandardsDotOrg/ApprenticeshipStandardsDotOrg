require "rails_helper"

RSpec.describe "layouts/_alerts.html.erb", type: :view do
  context "with alert" do
    it "allows to dismiss the alert flash message" do
      render partial: "layouts/alerts", locals: {alert: "Sample alert"}

      expect(rendered).to have_css "[aria-label=Close]"
      expect(rendered).to have_css "[role=button]"
      expect(rendered).to have_css '[data-action="click->dismissable#dismiss"]'
      expect(rendered).to have_css '[data-controller="dismissable"]'
      expect(rendered).to have_text "Sample alert"
    end
  end

  context "with notice" do
    it "allows to dismiss the notice flash message" do
      render partial: "layouts/alerts", locals: {notice: "Sample notice"}

      expect(rendered).to have_css "[aria-label=Close]"
      expect(rendered).to have_css "[role=button]"
      expect(rendered).to have_css '[data-action="click->dismissable#dismiss"]'
      expect(rendered).to have_css '[data-controller="dismissable"]'
      expect(rendered).to have_text "Sample notice"
    end
  end
end
