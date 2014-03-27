require "rubygems"
require "selenium-webdriver"
require "pry"

module LegoWishlist
  class PhantomBrowse
    
    def initialize(url)
      @driver = Selenium::WebDriver.for(:remote, :url => url)
    end

    def login
      binding.pry
      @driver.navigate.to "http://google.com"
      element = @driver.find_element(:name, 'q')
      element.send_keys "PhantomJS"
      element.submit
      puts @driver.title
      @driver.quit
    end
  end
end

a = LegoWishlist::PhantomBrowse.new("http://localhost:9134")
a.login
