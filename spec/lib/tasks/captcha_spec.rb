require "rails_helper"

Rails.application.load_tasks unless Rake::Task.task_defined?("captcha:enable")

describe "#enable" do
  after do
    Rake::Task["captcha:enable"].reenable
  end

  it "sets to true the recaptcha flag" do
    Flipper.disable(:recaptcha)
    Rake::Task["captcha:enable"].invoke

    expect(Flipper.enabled?(:recaptcha)).to be true
  end
end

describe "#disable" do
  after do
    Rake::Task["captcha:disable"].reenable
  end

  it "sets to false the recaptcha flag" do
    Flipper.enable(:recaptcha)
    Rake::Task["captcha:disable"].invoke

    expect(Flipper.enabled?(:recaptcha)).to be false
  end
end
