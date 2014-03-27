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
    
    def choose_color(colors)
      loop do
        HighLine.choose do |menu|
          menu.prompt = "Choose a color:  "
          colors.each do |color|
            menu.choice(color.to_sym) {return color}
          end
        end
      end
    end
    
    def initialize(ignore_ssl=false, debug=false)
      # Implement a custom driver because we have a few options we need to pass to the browser.
      Capybara.register_driver :webkit_custom do |app|
        browser = Capybara::Webkit::Browser.new(Capybara::Webkit::Connection.new).tap do |browser|
          # In case we also want to ignore SSL errors
          if ignore_ssl == true
            browser.ignore_ssl_errors
          end
          # Set up a blacklist for Google Analytics because it slows things down
          blacklist = []
          blacklist.push('http://www.google-analytics.com/ga.js')
          blacklist.push('http://js.brickowl.com/files/js/js_3kpuFG9hplasnVNukLtlogTthC4yQ3rb-C3J9yFlU4c.js')
          browser.url_blacklist = blacklist
          # Skip loading images because we shouldn't need them.
          browser.set_skip_image_loading(true)
        end
        driver = Capybara::Webkit::Driver.new(app, :browser => browser)
        # In case we want debugging output.
        if debug == true
          driver.enable_logging
        end
        driver
      end
      Capybara.current_driver = :webkit

      # Set up Capybara
      Capybara.run_server = false
      Capybara.app_host = "http://www.brickowl.com/"

      @logged_in = false 
   
      # Start headless server for Capybara to run in 
      headless = Headless.new
      headless.start
    end

    def login(username, password)
      page.driver.header("User-Agent", "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:27.0) Gecko/20100101 Firefox/27.0")
      binding.pry
      visit('user?destination=home')
      puts('1')
      if has_field? "name" and has_field? "pass"
        fill_in("name", :with => username)
        fill_in("pass", :with => password)
        evaluate_script("jQuery('form').submit()")

        if !find('strong').text.eql? username
          puts ("Something has gone wrong with the login!")
          exit 1
        end
        puts('2') 
        @logged_in = true
        
        return true
      else
        puts("Something has gone wrong. Has the website changed?")
        return false
      end
    end
    
    def add_to_wishlist(wishlist, brick)
      if @logged_in
        puts("Adding #{brick['name']} to #{wishlist['name']}")
        puts('3') 
        # Set up the wishlist form
        visit(brick['href'])
        find('#tab-wishlist a').click
        sleep(1)
        puts('4') 
        # There's bound to be more than one color
        colors = []
        all('#edit-color option').each do |option|
          if option.text.include? brick['color']
            colors.push(option.text)
          end
        end
        puts('5') 
        # Make the use choose
        if colors.length > 1
          brick['color'] = choose_color(colors)
        else
          brick['color'] = colors[0]
        end
        
        binding.pry 
      else
        puts("Must in first.")
        return false
      end
    end
  end
end

a = LegoWishlist::CapyBrowse.new(ignore_ssl=true, debug=true)
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
