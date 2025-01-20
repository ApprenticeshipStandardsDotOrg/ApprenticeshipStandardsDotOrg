namespace :captcha do
  task enable: :environment do
    Flipper.enable(:recaptcha)
  end

  task disable: :environment do
    Flipper.disable(:recaptcha)
  end
end
