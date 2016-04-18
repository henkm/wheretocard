module Wheretocard

  class Client
    # @note The is a required parameter.
    attr_accessor :username
    # @return [String] Your Wheretocard password
    attr_accessor :password
    # @return [String] Your Wheretocard client code
    attr_accessor :client_code
    # @return [String] Your Wheretocard case code
    attr_accessor :case_code


    #
    # Initializer to transform a +Hash+ into an Client object
    #
    # @param [Hash] args
    def initialize(args=nil)
      required_args = [:username, :password, :client_code, :case_code]
      for arg in required_args
        if args.nil? || args[arg].nil?
          raise WheretocardError.new(self), "Insufficient login credentials. Please provide @username, @password, @client_code and @case_code"
        end
      end

      return if args.nil?
      args.each do |k,v|
        instance_variable_set("@#{k}", v) unless v.nil?
      end
    end

    def check_credentials(product_code="")
      o = order
      o.add_line_item(
        price: 0, 
        description: 'Checking credentials [TEST]', 
        ticket_ref: 1234,
        valid_from: Time.now,
        valid_until: Time.now + 24*31*3600,
        product_code: product_code, 
        quantity: 0
      )
      begin
        o.submit
      rescue WheretocardError => e
        # return true if the error raised is only about the
        # number of tickets (cannot be zero)
        e.to_s.include?("OI_0210")
      end
      
    end

    # def order_requests
    #   Wheretocard::Order
    # end
    # alias :order_request :order_requests

    def order(args={})
      Wheretocard::Order.new({client: self}.merge(args))
    end
    alias :orders :order
    alias :new_order :order
    alias :add_order :order

  end
end
