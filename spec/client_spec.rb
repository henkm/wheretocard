require 'spec_helper'

describe Wheretocard::Client do

	context "valid settings" do

		before(:each) do
			@client = Wheretocard::Client.new(
									username: ENV['WHERETOCARD_USERNAME'], 
									password: ENV['WHERETOCARD_PASSWORD'],
									client_code: ENV['WHERETOCARD_CLIENT_CODE'],
									case_code: ENV['WHERETOCARD_CASE_CODE']
								)
		end

	  it "initializes as a 'Wheretocard::Client' object" do
	  	expect(@client).to be_kind_of(Wheretocard::Client)
	  end

	  describe "#check_credentials" do
	  	it "returns ok if credentials match" do
	  		VCR.use_cassette("check-credentials") do 
		  		expect(@client.check_credentials(ENV["WHERETOCARD_TICKET_KIND_1"])).to eq true
		  	end
	  	end

	  	it "returns message if credentials don't match" do
	  		@client.username = "wrongusername"
	  		VCR.use_cassette("check-wrong-credentials") do 
		  		expect(@client.check_credentials).to eq false
		  	end
	  	end
	  end

	  describe "#orders" do

	  	it "respons to orders" do
		  	expect(@client.orders).to be_kind_of(Wheretocard::Order)
		  end
		  
		  it "respons to order" do
		  	expect(@client.orders).to be_kind_of(Wheretocard::Order)
		  end

	  	it "respons to orders" do
	  		request = @client.order
		  	expect(request.client.username).to eq(ENV['WHERETOCARD_USERNAME'])
		  end

		  it "ititializes a new object through a hash" do
			 	request = @client.order(first_name: "Foo", last_name: "Bar")
			  expect(request.first_name).to eq("Foo")
			  expect(request.last_name).to eq("Bar")
			end

	  end

	end

  context "errors" do

	 	it "requires a username" do
	  	expect { Wheretocard::Client.new() }.to raise_error(WheretocardError, "Insufficient login credentials. Please provide @username, @password, @client_code and @case_code")
  	end

  end


end
