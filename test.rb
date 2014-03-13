require "rubygems"
require "capybara"
require "capybara/dsl"
require "capybara-webkit"
require "headless"
require "pry"

Capybara.run_server = false
Capybara.current_driver = :webkit
Capybara.app_host = "http://www.brickowl.com/"

module LegoWishlist
  class CapyBrowse
  include Capybara::DSL
    def add 
      Headless.ly do
        page.driver.header("User-Agent", "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:27.0) Gecko/20100101 Firefox/27.0")
        visit('user?destination=home')
        binding.pry
        if has_field? "name" and has_field? "pass"

        else
          puts("Something has gone wrong. Has the website changed")
          exit 1
        end
      end
    end
  end
end

a = LegoWishlist::CapyBrowse.new
a.add
