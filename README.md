# Belated

[![CodeFactor](https://www.codefactor.io/repository/github/sampokuokkanen/belated/badge)](https://www.codefactor.io/repository/github/sampokuokkanen/belated) [![Gem Version](https://badge.fury.io/rb/belated.svg)](https://badge.fury.io/rb/belated)

This is Belated, a new Ruby backend job library! It supports running procs, lambdas and classes in the background. To deal with restarts, it uses YAML to load the queue into a file, which it then calls at startup to find the previous jobs. There is no way in Ruby to save procs or lambdas to a file, so they are discarded when the process restarts.

Belated uses the Ruby Queue class, so it's First In, First Out (FIFO). 

Note that Belated used to be called HardWorker. That name was already in use in Sidekiq documentation and a bit too generic anyway. 

It uses dRuby to do the communication! Which is absolute great. No need for Redis or PostgreSQL, just Ruby standard libraries.

Note that currently the timezone is hardcoded to UTC. 

Can be used with or without Rails. 

TODO LIST:

- Use GDBM for queue storage? That way could maybe get rid of YAML dumping and make things a bit safer. Not ordered though, so maybe keep a list of the jobs as YAML and update it sometimes? Just as backup. 
- Rescue `DRb::DRbRemoteError` when shutting down, might not need to if using GDBM?
- Don't use class instance variables.
- Make DRb port configurable.
- Don't hardcode timezone.
- Add some checks to the client for proper jobs.
- Have multiple queues?
- Maybe support ActiveJob?
- Have a web UI.
- Have a job history
- Do some performance testing.
- Deploy a Rails app to production that is using Belated
  and mention it in the readme. (Capistrano support?)
  ([Wasurechatta](https://wasurechatta.com/))
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
class DumDum
  # classes need to have a perform method
  def perform
    5 / 4
  end
end

client = Belated::Client.new
client.perform_belated(proc { 2 / 1 })
client.perform_belated(DumDum.new)
# client.perform, client.perform_later are also good
# if you want to do something later:
client.perform_belated(DumDum.new, at: Time.now + 5 * 60)
# max retries:
client.perform_belated(DumDum.new, max_retries: 3) # default 5
```

Belated runs on localhost, port 8788. 
Going to make that an option in the future.

## Rails

Usage with Rails:
First, start up Belated.
Then,

```ruby
# Get the client
client = Belated::Client.instance
# Start the client, only need to do this once
client.start unless client.started?
```

and you can use the client!
Note that the client is a singleton. 
This means that you can only have one client running at a time, 
but it also means you only have one connection to dRuby, and that the number of threads in charge of queuing the jobs is only one.

Call

```ruby
job = proc { 2 / 1 }
client.perform_belated(job)
```

If you want to pass a job to Belated.

If you don't want the job to run right away, you can also pass it a keyword param `at:` like so:

```ruby
client.perform_belated(job, Time.now + 1.month)
```

The client also holds references to the jobs that are instances of `Proc` that have been pushed so that they are not collected by GC. This is because procs are passed by reference, and the client needs to keep them alive. They are removed from the list when the job is done.

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


# Possible problems

If you have the port 8788 already in use, you can check the ports in use in Linux with the following command:

    $ sudo lsof -i -P -n | grep LISTEN
## Contributing

Bug reports, questions and pull requests are welcome on GitHub at https://github.com/sampokuokkanen/belated. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/sampokuokkanen/belated/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Belated project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/sampokuokkanen/belated/blob/main/CODE_OF_CONDUCT.md).
