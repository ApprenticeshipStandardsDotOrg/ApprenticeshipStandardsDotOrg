require "rails_helper"

RSpec.describe Course, type: :model do
  it "has a valid factory" do
    course = build(:course)

    expect(course).to be_valid
  end

  it "has unique title and code wrt organization_id" do
    course = create(:course, code: "A1")
    new_course = build(:course, code: "A1", organization_id: course.organization_id)

    expect(new_course).to_not be_valid
    new_course.title = "New Title"
    new_course.code = "B2"
    expect(new_course).to be_valid
  end
end
