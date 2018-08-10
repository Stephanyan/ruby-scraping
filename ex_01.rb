# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'

# Return an array of urls of all townhalls in 95
def get_all_the_urls_of_val_doise_townhalls
  urls = []

  directory = Nokogiri::HTML(open('http://annuaire-des-mairies.com/val-d-oise.html'))
  directory.css('a[class = lientxt]').each do |element|
    # element => <a class="lientxt" href="./95/nom-de-la-ville.html">NOM DE LA VILLE</a>
    link = element['href']
    link[0] = ''
    urls << "http://annuaire-des-mairies.com#{link}"
  end

  urls
end

# Return an array of all emails
def get_all_emails
  urls = get_all_the_urls_of_val_doise_townhalls
  emails = []

  urls.each do |url|
    emails << get_the_email_of_a_townhal_from_its_webpage(url)
  end

  emails
end

# Return the email of the townhalls
def get_the_email_of_a_townhal_from_its_webpage(page_url)
  email = ''

  element_xpath = '/html/body/div/main/section[2]/div/table/tbody/tr[4]/td[2]'

  page = Nokogiri::HTML(open(page_url))
  page.xpath(element_xpath).each do |node|
    email = node.text
  end

  email
end

# Return an array of cities names
def get_cities_names
  name_of_cities = []

  doc = Nokogiri::HTML(open("http://annuaire-des-mairies.com/val-d-oise.html"))
  doc.xpath('//p/a').each do |town|
    name_of_cities << town.text
  end

  name_of_cities
end

# Display list of cities with their name, url and emails
def display_cities(name_of_cities, urls, emails)
  i = 0
  while i < urls.length
    puts "name  => #{name_of_cities[i]}"
    puts "url   => #{urls[i]}"
    puts "email => #{emails[i]}"
    puts '==========='
    i += 1
  end
end

def perform
  display_cities(get_cities_names, get_all_the_urls_of_val_doise_townhalls, get_all_emails)
end

perform
