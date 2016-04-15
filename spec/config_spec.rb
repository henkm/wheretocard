require 'spec_helper'

describe Wheretocard do

  it "returns correct version number" do
  	expect(Wheretocard.version).to eq(Wheretocard::VERSION)
  end

	context "API configuration" do

    it "should have the proper URL" do
      expect(Wheretocard.url).to eq("https://ticketing.wheretocard.nl/ticketService/submitOrder")
    end

	end
end
