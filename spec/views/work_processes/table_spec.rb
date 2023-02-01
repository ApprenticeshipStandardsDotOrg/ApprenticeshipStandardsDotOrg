require "rails_helper"

RSpec.describe "work_processes/_table.html.erb", type: :view do
  it "displays title, sort order, description, default hours, minimum hours and maximum hours", :admin do
    work_processes = create_list(:work_process, 1)
    work_process = work_processes.first

    render partial: "work_processes/table", locals: {work_processes: work_processes}

    expect(rendered).to have_columnheader("Title")
    expect(rendered).to have_columnheader("Sort Order")
    expect(rendered).to have_columnheader("Description")
    expect(rendered).to have_columnheader("Default Hours")
    expect(rendered).to have_columnheader("Minimum Hours")
    expect(rendered).to have_columnheader("Maximum Hours")

    expect(rendered).to have_gridcell(work_process.title)
    expect(rendered).to have_gridcell(work_process.sort_order)
    expect(rendered).to have_gridcell(work_process.description)
    expect(rendered).to have_gridcell(work_process.default_hours)
    expect(rendered).to have_gridcell(work_process.minimum_hours)
    expect(rendered).to have_gridcell(work_process.maximum_hours)
  end
end
