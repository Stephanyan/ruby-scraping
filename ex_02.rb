# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'

@doc = Nokogiri::HTML(open('https://coinmarketcap.com/all/views/all/'))

def all_currencies
  currencies = []

  @doc.css('.currency-name-container').each do |element|
    currencies << element.text
  end

  currencies
end

def all_prices
  prices = []

  @doc.css('a[class = price]').each do |element|
    prices << element.text
  end

  prices
end

def build_hash(currencies, prices)
  currencies_hash = {}

  currencies.each_with_index do |currency, index|
    currencies_hash[currency] = prices[index]
  end

  currencies_hash
end

def perform
  p build_hash(all_currencies, all_prices)
end

perform
