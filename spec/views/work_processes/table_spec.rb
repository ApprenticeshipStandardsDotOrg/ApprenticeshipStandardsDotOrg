require "rails_helper"

RSpec.describe "work_processes/_table.html.erb", type: :view do
  it "displays title, sort order, description, default hours, minimum hours and maximum hours", :admin do
    work_processes = create_list(:work_process, 1, minimum_hours: 10, maximum_hours: 20)
    work_process = work_processes.first

    render partial: "work_processes/table", locals: {work_processes: work_processes}

    expect(rendered).to have_columnheader("Title")
    expect(rendered).to have_columnheader("Skills")
    expect(rendered).to have_columnheader("Hours")

    expect(rendered).to have_gridcell(work_process.title)
    expect(rendered).to have_gridcell("10-20")
  end
end
