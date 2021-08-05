# Belated

[![CodeFactor](https://www.codefactor.io/repository/github/sampokuokkanen/belated/badge)](https://www.codefactor.io/repository/github/sampokuokkanen/belated) [![Gem Version](https://badge.fury.io/rb/belated.svg)](https://badge.fury.io/rb/belated)

This is Belated, a new Ruby backend job library! It supports running procs and classes in the background. To deal with restarts, it uses YAML to load the queue into a file, which it then calls at startup to find the previous jobs.

Note that Belated used to be called HardWorker. That name was already in use in Sidekiq documentation and a bit too generic anyway. 

It uses dRuby to do the communication! Which is absolute great. No need for Redis or PostgreSQL, just Ruby standard libraries.

Can be used with or without Rails. 

TODO LIST:

- Add some checks to the client for proper jobs.
- Don't crash on errors (Partially done)
- Have multiple queues?
- Maybe support ActiveJob?
- Have a web UI
- Do some performance testing
- Deploy a Rails app to production that is using Belated
  and mention it in the readme. 
- Add a section telling people to use Sidekiq if they can

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'belated'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install belated

## Usage

Start up Belated!

    $ belated

Then, in another program, connect to Belated and give it a job to do.
Sample below:

```ruby
class DummyWorker
  attr_accessor :queue

  def initialize
    server_uri = Belated::URI
    self.queue = DRbObject.new_with_uri(server_uri)
  end
end

class DumDum
  # classes need to have a perform method
  def perform
    5 / 4
  end
end

# Need to start dRuby on the client side
DRb.start_service
dummy = DummyWorker.new
dummy.queue.push(proc { 2 / 1 })
dummy.queue.push(DumDum.new)
```

Belated runs on localhost, port 8788. 
Going to make that an option in the future.

## Rails

Usage with Rails:
First, start up Belated.
Then,

```ruby
client = Belated::Client.new
```

and you can use the client!
Call

```ruby
client.perform_belated(job)
```

If you want to pass a job to Belated.

If you don't want the job to run right away, you can also pass it a keyword param `at:` like so:

```ruby
client.perform_belated(job, Time.now + 1.month)
```

Note that you probably want to memoize the client, as it always creates a 'banker thread' now if you have no connection. Maybe even use it as a global!(`$client`)

# Settings

Configuring Belated:

```ruby
Belated.configure do |config|
  config.rails = false # default is true
  config.rails_path = # './dummy' default is '.'
  config.connect = false # Connect to dRuby, default is true, useful for testing only
  config.workers = 2 # default is 1
end
```

From command line:

    $ bundle exec belated --rails=true

Use Rails or not.

    $ bundle exec belated --rails_path=/my_rails_project

Path to Rails project.

    $ bundle exec belated --workers=10

Number of workers.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sampokuokkanen/belated. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/sampokuokkanen/belated/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Belated project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/sampokuokkanen/belated/blob/main/CODE_OF_CONDUCT.md).
