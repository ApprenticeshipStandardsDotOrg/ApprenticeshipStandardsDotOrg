class Scraper::WatirJob < ApplicationJob
  private

  def configure_watir_browser
    if (chromedriver_path = ENV.fetch("CHROMEDRIVER_PATH", nil))
      Selenium::WebDriver::Chrome::Service.driver_path = chromedriver_path
    end

    options = {
      args: %w[--no-sandbox --headless --disable-dev-shm-usage --disable-gpu]
    }
    if (chrome_bin = ENV.fetch("GOOGLE_CHROME_SHIM", nil))
      options[:binary] = chrome_bin
    end

    Watir::Browser.new(:chrome, options: options)
  end
end
