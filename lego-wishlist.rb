require 'mechanize'
require 'highline/import'

BRICKOWL_URL = "http://www.brickowl.com/"

a = Mechanize.new

a.get(BRICKOWL_URL)

# Goto Login Page
a.click('Login')

# Fill login form
username = ask("Enter your username:  ") { |q| q.echo = true }
password = ask("Enter your password:  ") { |q| q.echo = "*" }







