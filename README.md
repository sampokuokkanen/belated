# Belated

[![CodeFactor](https://www.codefactor.io/repository/github/sampokuokkanen/belated/badge)](https://www.codefactor.io/repository/github/sampokuokkanen/belated) [![Gem Version](https://badge.fury.io/rb/belated.svg)](https://badge.fury.io/rb/belated)

This is Belated, a new Ruby backend job library! It supports running procs, lambdas and classes in the background. To deal with restarts, it uses YAML for the current jobs in the queue waiting to be processed and PStore for the future jobs to load the queues into a file, which it then calls at startup to find the previous jobs. There is no way in Ruby to save procs or lambdas to a file, so they are discarded when the process restarts.

Belated uses the Ruby Queue class, so it's First In, First Out (FIFO), unless of course you want to run the job in the future. In that case the order is decided by the time the job is scheduled to be executed. 

It uses dRuby to do the communication! Which is absolute great. No need for Redis or PostgreSQL, just Ruby standard libraries.

Can be used with or without Rails. 

Can be used if you're on a normal instance such as EC2 or Digital Ocean drop. Not if you're on a Heroku or Docker, or anything with ephemeral storage. 

TODO LIST:

- Have a web UI with job history.
- Deploy a Rails app to production that is using Belated
  and mention it in the readme. (Capistrano support?)
  ([Wasurechatta](https://wasurechatta.com/) deployed, still need to setup Capistrano)

# Why not Sidekiq? 

If you can, definitely use Sidekiq!!! Belated is supposed to be used if you can't get anything else to work. Like if you want to use SQLite in a Rails app and don't want to have Redis running. Or maybe you just want to run procs in the background? 

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

If you're using Rails, just set Belated to be the ActiveJob adapter like below:

```ruby
config.active_job.adapter = :belated
```

And you're good to go!

If not, in your non-ActiveJob using program, connect to Belated and give it a job to do.
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

Other available settings:

    $ bundle exec belated --host=1.1.1.1 --port=1234 
    # druby://1.1.1.1:1234
    $ bundle exec belated --env=test
    # environment
    $ bundle exec belated --client_heartbeat=10
    # how often client sends jobs to server, default is once every 5 seconds


Number of workers.

## Testing

When testing, you can require `belated/testing` and then call `Belated::Testing.inline!` to make your jobs perform inline.

```ruby
`belated/testing`
c = Belated::Client.instance
c.perform(proc { 2/ 1}) # Tries to push the job to the drb backend
# <Belated::JobWrapper:0x00005654bc2db1f0 @at=nil, @completed=false, @id="95e4dc6a-1876-4adf-ae0f-5ae902f5f024", @job=#<Proc:0x00005654bc2db330 (irb):3>, @max_retries=5, @proc_klass=true, @retries=0>
Belated::Testing.inline! # Sidekiq-inspired, now jobs run inline
c.perform(proc { 2/ 1}) # Returns 2 right away
# 2
Belated::Client.test_mode_off! # Turn off inline job processing
```

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
