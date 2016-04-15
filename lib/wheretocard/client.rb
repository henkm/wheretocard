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
