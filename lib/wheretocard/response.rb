module Wheretocard


  #
  # Object representing a response object with attributes provided by WTC
  #
  # @return [Array] Errors
  # @param :amount [Integer] The total price in cents
  class Response
    attr_accessor :errors
    attr_accessor :body
    attr_accessor :comment
		attr_accessor :status
		attr_accessor :url

    #
    # Initializer to transform a +Hash+ into an Payment object
    #
    # @param [Hash] args
    def initialize(args=nil)
      @line_items = []
      return if args.nil?
      args.each do |k,v|
        instance_variable_set("@#{k}", v) unless v.nil?
      end
    end

    # raise errors if the API returns errors
    def validate
    	if nokogiri_document.xpath('//error').any?
    		code = nokogiri_document.xpath('//code').text
    		desc = nokogiri_document.xpath('//description').text
    		raise WheretocardError.new(self), "#{desc}\nError code: #{code} (#{error_codes[code]})"
    	end
    end

    # return true if status is "OK"
    def success
    	status == "OK"
    end
    alias :success? :success

    # return the parsed xml document
		def nokogiri_document 
			@nokogiri_document ||= Nokogiri::XML(body)
		end

		def error_codes
			{
				"OI_0001" => "Internal server error",
				"OI_0099" => "Unknown error",

				"OI_0101" => "Supplied client not found",
				"OI_0102" => "Interface not enabled for client",

				"OI_0201" => "Submitted client not found",
				"OI_0202" => "Interface not enabled for client",
				"OI_0203" => "Missing (or empty) order reference id attribute.",
				"OI_0204" => "Request contains invalid orderline.ticket-ref <-> ticket.ref link reference(s)",
				"OI_0205" => "Unknown delivery channel",
				"OI_0206" => "Unknown delivery format",
				"OI_0207" => "Device manufacturerer/type is not known",
				"OI_0208" => "The delivery address is not specified",
				"OI_0209" => "The submitted data for order reference id (max 32 chars), or one of the
properties (max 100 chars) is too long.",
				"OI_0210" => "Submitted number of persons is negative or 0",
				"OI_0211" => "Submitted times valid is negative or 0",
				"OI_0212" => "Supplied email address is missing or the format is not correct",
				"OI_0213" => "The submitted orderline type does not belong to the client",
				"OI_0214" => "Missing required orderlinetype",
				"OI_0215" => "Orderline type is not owned by the submitted case",
				"OI_0216" => "Could not generate ticket code for request, all ticket codes are in use (batch
full).",
			}
		end

    def self.parse_respose_code(order, code)
    	if code == 200
    		return
    	elsif code == 500
    		raise WheretocardError.new(order), "A server error occured (500)"
    	else
				raise WheretocardError.new(order), "The request failed (http status code #{code})"
    	end
    end

    def self.from_order_request(order)
			response = HTTParty.post(Wheretocard.url, body: order.to_xml)
			# puts response.body, response.code, response.message, response.headers.inspect
			

			# raise error if code is not 200
			parse_respose_code(order, response.code)

			# parse the response
			# <orderResponse status="NOT_OK">
			# 	<error>
			# 		<code>OI_0202</code>
			# 		<description><![CDATA[Posted XML not valid, or not conform Schema definition. ]]></description>
			# 	</error>
			# </orderResponse>
			
			r = Response.new()
			r.body = response.body
			r.status = r.nokogiri_document.xpath('//orderResponse/@status').text
			if r.nokogiri_document.search('comment[type="url"]').any?
				r.url = r.nokogiri_document.search('comment[type="url"]').first.text
			end
			r.validate
			return r
    end

  end
end
