module Wheretocard

  # Creates a validator
  class OrderValidator
    # include Veto.validator
    # validates :value, presence: true, integer: true
    # validates :profile, presence: true
    # validates :currency, presence: true, format: /[A-Z]{3}/
    # validates :email, presence: true
  end



  #
  # Object representing a response object with attributes provided by WTC
  #
  # @return [Array] Errors
  # @param :amount [Integer] The total price in cents
  class Order
    attr_accessor :errors
    attr_accessor :reference_id
    attr_accessor :first_name
    attr_accessor :infix
    attr_accessor :last_name
    attr_accessor :street
    attr_accessor :house_number
    attr_accessor :city
    attr_accessor :postal_code
    attr_accessor :country
    attr_accessor :email
    attr_accessor :phone_number
    attr_accessor :value
    attr_accessor :client
    attr_accessor :line_items
    attr_accessor :delivery_format
    attr_accessor :delivery_channel


    #
    # Initializer to transform a +Hash+ into an Payment object
    #
    # @param [Hash] args
    def initialize(args=nil)
      @line_items = []
      @delivery_format = "BARCODE"
      @delivery_channel = "WEB"
      return if args.nil?
      args.each do |k,v|
        instance_variable_set("@#{k}", v) unless v.nil?
      end
    end

    # @return [Boolean] true/false, depending if this instanciated object is valid
    def valid?
      validator = OrderValidator.new
      validator.valid?(self)
    end

    # 
    # This is the most importent method. It uses all the attributes
    # and performs a `order` action on Wheretocard API. 
    # @return [Wheretocard::Response] response object with `key`, `message` and `success?` methods
    # 
    def create
      # if there are any line items, they should all be valid.
      validate_line_items

      # make the API call
      # response        = Docdata.client.call(:create, xml: create_xml)
      # response_object = Docdata::Response.parse(:create, response)
      if response_object.success?
        self.key = response_object.key
      end

      # set `self` as the value of the `payment` attribute in the response object
      response_object.payment = self
      response_object.url     = redirect_url

      return response_object
    end

    # adds a line item of type LineItem to the line_items atribute (array)
    def add_line_item(args=nil)
      line_item = Wheretocard::LineItem.new(args)
      line_items << line_item
      return line_item
    end

    # @return [String] the xml to send in the SOAP API
    def to_xml
      xml_file        = "#{File.dirname(__FILE__)}/xml/order_request.xml.erb"
      template        = File.read(xml_file)      
      namespace       = OpenStruct.new(order: self, client: client)
      xml             = ERB.new(template).result(namespace.instance_eval { binding })
    end
    alias :xml :to_xml

    # submit the xml to the WtC API url 
    # return object is a Wheretocard::Response
    def submit
      # validate_line_items
      Wheretocard::Response.from_order_request(self)
    end

  end

  private

  # make sure all the line items are valid
  def validate_line_items
    
  end
end
