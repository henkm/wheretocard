require 'spec_helper'

describe Wheretocard::Order do
  before(:each) do
    @client = Wheretocard::Client.new(
                username: ENV['WHERETOCARD_USERNAME'], 
                password: ENV['WHERETOCARD_PASSWORD'],
                client_code: ENV['WHERETOCARD_CLIENT_CODE'],
                case_code: ENV['WHERETOCARD_CASE_CODE']
              )
    @order = @client.new_order(first_name: "Foo", last_name: "Bar")
  end

  describe "initialisation" do

    it "has a name" do
      expect(@order.first_name).to eq("Foo")
    end

  end

  describe "#to_xml" do
    it "generates an xml string from erb template" do
      xml = @order.to_xml
      # puts xml
      expect(xml).to be_kind_of(String)
    end
  end

  describe "#add_line_item" do
    it "adds a line item" do
      expect(@order).to be_kind_of(Wheretocard::Order)
      expect(@order.line_items.count).to eq 0
      @order.add_line_item(product_code: "xxx", quantity: 1, price: 1000, description: 'test ticket')
      expect(@order.line_items.count).to eq 1
    end

    it "adds a line item to xml" do
      @order.add_line_item(product_code: "FOO_BAR", quantity: 1, price: 1000, description: 'test ticket')
      xml = @order.to_xml
      expect(xml).to be_kind_of(String)
      expect(xml).to match("FOO_BAR")
    end
  end

  describe "#submit" do

    it "sends a blank request to the API and raises error" do
      VCR.use_cassette("blank-order-request") do
        expect { @response = @order.submit }.to raise_error(/Posted XML not valid, or not conform Schema definition/)
      end
    end

    context "valid xml with BARCODE" do
      before(:each) do
        @order.email = "foobar@example.org"
        @order.street = "My Street"
        @order.house_number = "123"
        @order.postal_code = "1234AB"
        @order.city = "My City"
        @order.delivery_format = "BARCODE"
        @order.reference_id = rand(9999)
        @order.add_line_item(
          product_code: ENV["WHERETOCARD_TICKET_KIND_1"], 
          quantity: 2, 
          price: 1, 
          description: 'test ticket', 
          ticket_ref: 1234,
          valid_from: Time.now,
          valid_until: Time.now + 24*31*3600
        )
        VCR.use_cassette("valid-order-request") do    
          # puts @order.xml
          @response = @order.submit
        end
      end

      it "sends valid xml and returns response object" do
        expect(@response).to be_kind_of Wheretocard::Response
      end

      it "has status OK" do
        expect(@response.status).to eq("OK")
      end

      it "is a success" do
        expect(@response).to be_success
      end

      it "has an URL starting with https" do
        expect(@response.url).to match("https://")
      end
    end  


    context "valid xml with TEXTCODE" do
      before(:each) do
        @order.email = "foobar@example.org"
        @order.street = "My Street"
        @order.house_number = "123"
        @order.postal_code = "1234AB"
        @order.city = "My City"
        @order.delivery_format = "TEXTCODE"
        @order.delivery_channel = "WEB"
        @order.reference_id = rand(9999)
        @order.add_line_item(
          product_code: ENV["WHERETOCARD_TICKET_KIND_1"], 
          quantity: 1, 
          price: 1000, 
          description: 'test ticket', 
          ticket_ref: 1234,
          valid_from: Time.now,
          valid_until: Time.now + 24*31*3600
        )
        VCR.use_cassette("valid-order-textcode-request") do    
          # puts @order.xml
          @response = @order.submit
        end
      end

      it "sends valid xml and returns response object" do
        expect(@response).to be_kind_of Wheretocard::Response
      end

      it "has status OK" do
        expect(@response.status).to eq("OK")
      end

      it "is a success" do
        expect(@response).to be_success
      end

      it "has an URL starting with https" do
        expect(@response.url).to match("https://")
      end
    end  

    context "valid xml with custom codes" do
      before(:each) do
        @order.email = "foobar@example.org"
        @order.street = "My Street"
        @order.house_number = "123"
        @order.postal_code = "1234AB"
        @order.city = "My City"
        @order.delivery_format = "BARCODE"
        @order.delivery_channel = "WEB"
        @order.reference_id = rand(9999)
        for code in ["201600001", "201600002"]
          @order.add_line_item(
            barcode: code,
            product_code: ENV["WHERETOCARD_TICKET_KIND_1"], 
            quantity: 1, 
            price: 1, 
            description: 'test ticket', 
            ticket_ref: "CODE_#{code}",
            valid_from: Time.now,
            valid_until: Time.now + 24*31*3600
          )
        end
        VCR.use_cassette("valid-order-custom-code-request") do    
          # puts @order.xml
          @response = @order.submit
        end
      end

      it "sends valid xml and returns response object" do
        expect(@response).to be_kind_of Wheretocard::Response
      end

      it "has status OK" do
        expect(@response.status).to eq("OK")
      end

      it "is a success" do
        expect(@response).to be_success
      end

      it "has an URL starting with https" do
        expect(@response.url).to match("https://")
      end
    end      


  end

end
