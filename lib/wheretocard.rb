# Libraries
require 'ostruct'
require 'httparty'
# require 'uri'
# require 'rails'
# require 'active_support/dependencies'
# require 'active_support'
require 'open-uri'
require 'nokogiri'
# require 'veto'


#  Files
require "wheretocard/version"
require "wheretocard/config"
require "wheretocard/engine" if defined?(Rails) && Rails::VERSION::MAJOR.to_i >= 3
require "wheretocard/wheretocard_error"
require "wheretocard/client"
require "wheretocard/order"
require "wheretocard/line_item"
require "wheretocard/response"


# 
# Wheretocard Module
# 
module Wheretocard
  API_VERSION = 1

  # returns the version number
  def self.version
    VERSION
  end 

  def self.url
    "https://ticketing.wheretocard.nl/ticketService/submitOrder"
  end

end
