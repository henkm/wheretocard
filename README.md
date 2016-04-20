
# Wheretocard

The Wheretocard gem is a straight forward ruby binder for the Wheretocard API.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'wheretocard'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install wheretocard

## Usage

To request two barcodes from two different ticket kinds (4 barcodes in total), you can do the following:


```ruby
# Setup the WtC client with credentials
@wtc_client = Wheretocard::Client.new(
                username: yourusername,
                password: yourpassword,
                client_code: yourclientcode,
                case_code: yourcasecode
              )

# Check the credentials first, without making test orders
@wtc_client.check_credentials("TICKET_KIND_1_CODE") #returns true or false

# Initialize a new OrderRequest 
@order = @wtc_client.new_order
@order.first_name = "Foo"
@order.last_name = "Bar"
@order.email = "foobar@example.org"
@order.delivery_type = "BARCODE" # ["TEXTCODE","BARCODE"]

# Add line itmes to the request
# Please note: the price is in cents (currency is EUR)
@order.add_line_item(
  product_code: TICKET_KIND_1_CODE,
  quantity: 2,
  price: 1250,
  description: Action Description,
  valid_from: Time.now,
  valid_until: Time.now + 3.months
)

# It is also possible to not let WtC pick a barcode,
# but to submit your own barcode by adding the 'barcode' param
# WARNING: don't use quantity > 1 here, otherwise you'l create duplicate barcodes
# If you need multiple tickets for this ticket kind, simply create one line item
# per ticket.
@order.add_line_item(
  product_code: TICKET_KIND_3_CODE,
  price: 1750,
  description: Action Description,
  barcode: "ABC12345"
  valid_from: Time.now,
  valid_until: Time.now + 3.months
)


# Submit the request and receive a response object
@response = @order.submit

# redirect the consumer to the PDF download page:
if @response.success?
	redirect_to @response.url
    # => https://ticketing.wheretocard.nl/ticketService/print/printTicket?refId=xxx&ui=yyy
else
	# TODO: handle exception
end

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/henkm/wheretocard.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Credits and disclaimer

This gem is made with love by the smart people at [Eskes Media B.V.](http://www.eskesmedia.nl) and [dagjewegtickets.nl](https://www.dagjewegtickets.nl) 
Wheretocard is not involved with this project and has no affiliation with Eskes Media B.V.
