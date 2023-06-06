require 'capybara'
require 'capybara-screenshot/rspec'

## Headless!
Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new

  options.add_argument('--headless')
  options.add_argument('--disable-gpu')
  options.add_argument('--test-type')
  options.add_argument('--ignore-certificate-errors')
  options.add_argument('--disable-popup-blocking')
  options.add_argument('--disable-extensions')
  options.add_argument('--enable-automation')
  options.add_argument('--window-size=1920,1080')
  options.add_argument('--start-maximized')

  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    logging_prefs: { 'browser' => 'ALL' }
  )

  Capybara::Selenium::Driver.new app, browser: :chrome, options: options, desired_capabilities: capabilities
end

## Capy Configuration Defaults
Capybara.configure do |config|
  config.server = :puma
  driver = ENV['HEADLESS'] || ENV['H'] ? :headless_chrome : :selenium_chrome
  config.javascript_driver = driver
  config.default_max_wait_time = 7
  config.ignore_hidden_elements = false
end
