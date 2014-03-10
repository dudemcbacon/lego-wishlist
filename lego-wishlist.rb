require 'mechanize'
require 'highline/import'
require 'pp'

BRICKOWL_URL = "http://www.brickowl.com/"

a = Mechanize.new

a.get(BRICKOWL_URL) do |page|

  # Goto Login Page
  login_page = a.click(page.link_with(:text => /Login/))
 
  # Fill login form
  username = ask("Enter your username:  ") { |q| q.echo = true }
  password = ask("Enter your password:  ") { |q| q.echo = "*" }

  my_page = login_page.form_with(:action => '/user?destination=home') do |f|
    f.field_with(:name => "name").value = username
    f.pass = password
  end.submit

  if my_page.link_with(:href => 'https://www.brickowl.com/user').nil?
    die('Login failure.')
  end

end

item = ask("Enter an item number:  ") { |q| q.echo = true }.to_i

if item == 0
  die("Please enter an integer item number.")
end

a.get(BRICKOWL_URL + 'search/catalog?query=' + item.to_s) do |page|
  
  quantity = page.at('.amount').text.gsub("\n", "").split(" Item")[0]
  puts("Found #{quantity} item(s).")

  bricks = []
  page.search('.category-item').each_with_index do |item, index|
    brick = {}
    brick['title'] = item.at('.category-item-name a').attribute('title').text
    brick['href'] = item.at('.category-item-name a').attribute('href').text
    bricks[index] = brick
  end

  unless bricks.length < 2
    bricks.each_with_index do |brick, index|
      puts("#{index+1}: #{brick['title']}")
    end

    selection = ask("Which one? Enter a number:  ") { |q| q.echo = true }.to_i

    if item == 0
      die("Please enter an integer item number.")
    end
  
    selection = selection - 1
  
    puts("You chose: #{bricks[selection]['title']}")

    queried_brick = bricks[selection]  
  else
    queried_brick = bricks[0]
end
puts queried_brick
   
end





