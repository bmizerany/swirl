Swirl
=====

Swirl is an EC2 version agnostic client for EC2 writtin in Ruby. It gets
out of your way.

The secret is it's simple input extraction and output compacting.  Your
input parameters and `expand`ed and EC2's (terrible) xml output is
`compact`ed.


Some simple examples:

    # Input
    { "InstanceId" => ["i-123k2h1", "i-0234d3"] }

is `expand`ed to:

    { "InstanceId.0" => "i-123k2h1", "InstanceId.1" => "i-0234d3" }

and

    # Output
    {
      "reservationSet" => {
        "item" => {
          "instancesSet" => { "item" => [ ... ] }
        }
      }
    }

and it's varations are now `compact`ed to:

  {
    "reservationSet" => {
      "instancesSet" => [ { ... }, { ... } ]
    }
  }


Some things worth noteing is that compact ignores Symbols.  This
allows you to pass the params into `call` and use them later
without affecting the API call (i.e. chain of responsiblity); a
nifty trick we use in (Rack)[http://github.com/rack/rack]

Use
---

    ec2 = Swirl::EC2.new

    # Describe all instances
    ec2.call "DescribeInstances"

    # Describe specific instances
    ec2.call "DescribeInstances", "InstanceId" => ["i-38hdk2f", "i-93nndch"]

Test
----
To run the entire test suite

    % gem bundle
    % bin/rake test

To run a single test

    % gem exec ruby test/compactor_test.rb

