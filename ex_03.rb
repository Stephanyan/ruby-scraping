# frozen_string_literal: false

require 'nokogiri'
require 'open-uri'
require 'cgi'

@doc = Nokogiri::HTML(open('https://www.nosdeputes.fr/deputes'))

# Return an array of all deputies first names
def all_deputies_first_names(full_names)
  first_names = []

  full_names.each_with_index do |name, index|
    first_names << name if index.odd?
  end

  first_names
end

# Return an array containing all deputies last names
def all_deputies_last_names(full_names)
  last_names = []

  full_names.each_with_index do |name, index|
    last_names << name if index.even?
  end

  last_names
end

# Return an array containing all deputies full names
def all_deputies_full_names
  names = []

  @doc.css('span[class = list_nom]').each do |element|
    names << element.text.strip
  end

  names.map { |name| name.split(', ') }.flatten
end

# Return an array of all deputies profile urls
def all_urls(first_names, last_names)
  urls = []

  first_names_with_dashes = first_names.map do |name|
    CGI.escape(name.tr("[ ']", '-').gsub(/ö/, 'oe').downcase)
  end

  last_names_with_dashes = last_names.map do |name|
    CGI.escape(name.tr("[ ']", '-').gsub(/ö/, 'oe').downcase)
  end

  first_names_with_dashes.each_with_index do |name, index|
    urls << "https://www.nosdeputes.fr/#{name}-#{last_names_with_dashes[index]}"
  end

  urls
end

# Return the email of one deputy
def get_email(deputy_page_url)
  email = ''

  page = Nokogiri::HTML(open(deputy_page_url))

  page.css('a[@href ^="mailto:"]').each do |element|
    email << element.text
    break
  end

  email
end

# Display an array of hashes containing deputies info
def build_hash(emails, first_names, last_names)
  deputies_array = []

  emails.each_with_index do |email, index|
    deputy_hash = {}
    deputy_hash['first_name'] = first_names[index]
    deputy_hash['last_name'] = last_names[index]
    deputy_hash['email'] = email
    deputies_array << deputy_hash
  end

  deputies_array
end

# Main method
def perform
  emails = []
  first_names = all_deputies_first_names(all_deputies_full_names)
  last_names = all_deputies_last_names(all_deputies_full_names)

  all_urls(first_names, last_names).each do |url|
    emails << get_email(url)
  end

  p build_hash(emails, first_names, last_names)
end

perform
