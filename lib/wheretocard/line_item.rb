module Wheretocard
  #
  # Object representing a line item with attributes provided by WTC
  #
  # @return [Array] Errors
  class LineItem
    attr_accessor :errors
    attr_accessor :product_code
    # If a barcode is given, it'll be used. There is no check for
    # uniqueness. If no barcode is given, WtC will generate a unique one.
    attr_accessor :barcode
    attr_accessor :quantity
    attr_accessor :ticket_ref
    attr_accessor :price
    attr_accessor :description
    attr_accessor :valid_from
    attr_accessor :valid_until

    #
    # Initializer to transform a +Hash+ into an Payment object
    #
    # @param [Hash] args
    def initialize(args=nil)
      return if args.nil?
      args.each do |k,v|
        instance_variable_set("@#{k}", v) unless v.nil?
      end
    end


  end
end
