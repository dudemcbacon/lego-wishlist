require "rubygems"
require "selenium-webdriver"
require "pry"
require "headless"
require "highline/import"

module LegoWishlist
  class FirefoxBrowse
    
    def initialize(url)
      @driver = Selenium::WebDriver.for :firefox
      @wait = wait = Selenium::WebDriver::Wait.new(:timeout => 10)
      @logged_in = false
    end

    def login(username, password)
      @driver.navigate.to "https://www.brickowl.com/user?destination=home"
      puts @driver.title
      name = @driver.find_element(:name, "name")
      name.send_keys username
      @driver.execute_script("jQuery('#edit-pass').val('#{password}');")
      @driver.find_element(:id, "edit-submit").click
      begin
        name = @driver.find_element(:css, "strong").text
        if name == username
          @logged_in = true
        end
      rescue NoSuchElementError
        puts "Login failed. Has the website changed?"
      end  
    end

    def add_to_wishlist(wishlist, brick)
      if !@logged_in
        puts "Login first."
        exit
      end

      puts("Adding #{brick['name']} to #{wishlist['name']}")
      @driver.navigate.to("http://www.brickowl.com" + brick['href'])
      @driver.find_element(:css, "#tab-wishlist a").click
      sleep(1)
    end
  end
end

password = ask("Enter password: ") {|q| q.echo = "*"}
a = LegoWishlist::FirefoxBrowse.new("http://localhost:9134")
a.login("dudemcbacon", password)

brick = {}
brick['name'] = "LEGO Tile 2 x 2 (undetermined type) with Decoration"
brick['href'] = "/catalog/lego-tile-2-x-2-undetermined-type-with-decoration-123456"
brick['qty'] = 5
brick['color'] = "Black"

wishlist = {}
wishlist['name'] = "test123"
wishlist['href'] = "http://www.brickowl.com/wishlist/view/dudemcbacon/test123"

a.add_to_wishlist(wishlist, brick)
