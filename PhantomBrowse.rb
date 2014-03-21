require "rubygems"
require "selenium-webdriver"

module LegoWishlist
  class SeleniumBrowse
    
    def initialize(url)
      driver = Selenium::WebDriver.for(:remote, :url => url)
    end

    def login
      driver.navigate.to "http://google.com"
      element = drive.find_element(:name, 'q')
      element.send_keys "PhantomJS"
      element.submit
      puts driver.title
      driver.quit
    end
  end
end

a = LegoWishlist::SeleniumBrowse.new("http://localhost:9134")
a.login
