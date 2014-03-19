require "rubygems"
require "capybara"
require "capybara/dsl"
require "capybara-webkit"
require "headless"
require "pry"
require "highline/import"

module LegoWishlist
  class CapyBrowse
    include Capybara::DSL
    
    def initialize
      # Register new capybara driver to ignore SSL errors
      Capybara.register_driver :webkit_ignore_ssl do |app|
        browser = Capybara::Webkit::Browser.new(Capybara::Webkit::Connection.new).tap do |browser|
          browser.ignore_ssl_errors
        end
        Capybara::Webkit::Driver.new(app, :browser => browser)
      end

      # Set up Capybara
      Capybara.run_server = false
      Capybara.current_driver = :webkit_ignore_ssl
      Capybara.app_host = "http://www.brickowl.com/"

      @logged_in = false 
   
      # Start headless server for Capybara to run in 
      headless = Headless.new
      headless.start
    end

    def login(username, password)
      #Headless.ly do
        page.driver.header("User-Agent", "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:27.0) Gecko/20100101 Firefox/27.0")
        visit('user?destination=home')
        if has_field? "name" and has_field? "pass"
          fill_in("name", :with => username)
          fill_in("pass", :with => password)
          evaluate_script("jQuery('form').submit()")

          if !find('strong').text.eql? username
            puts ("Something has gone wrong with the login!")
            exit 1
          end
          
          @logged_in = true
        else
          puts("Something has gone wrong. Has the website changed?")
          exit 1
        end
      #end
    end
    
    def add_to_wishlist(wishlist, brick)
      if @logged_in
        #Headless.ly do
          puts("Adding #{brick['name']} to #{wishlist['name']}")
          visit(brick['href'])
          find('#tab-wishlist a').click
          sleep(1)
          all('#edit-color option').each do |option|
            if option.text.include? brick['color']
              puts option.text
            end
          end
          binding.pry
        #enkjd
      else
        puts("Must log in first.")
      end
    end
  end
end

a = LegoWishlist::CapyBrowse.new
password = ask("Enter password:  ") { |q| q.echo = "*" }

brick = {}
brick['name'] = "LEGO Tile 2 x 2 (undetermined type) with Decoration"
brick['href'] = "/catalog/lego-tile-2-x-2-undetermined-type-with-decoration-123456"
brick['qty'] = 5
brick['color'] = "Black"

wishlist = {}
wishlist['name'] = "test123"
wishlist['href'] = "http://www.brickowl.com/wishlist/view/dudemcbacon/test123"

a.login("dudemcbacon", password)
a.add_to_wishlist(wishlist, brick)
