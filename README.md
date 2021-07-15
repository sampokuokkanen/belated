# Hardworker

This is HardWorker, a new Ruby backend job library! It supports running procs in the background. 
However, it does not yet support classes. So only procs. Also, you lose all jobs if you restart the process. 

But it uses dRuby to do the communication! Which is absolute great. No need for Redis or PostgreSQL, just Ruby standard libraries. 

TODO LIST: 
- Marshal the job queue into a file so you don't lose all progress
- Support Rails and ActiveJob
- Have a web UI
- Do some performance testing
- Add a section telling people to use Sidekiq if they can

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hard_worker'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install hardworker

## Usage

Start up HardWorker! 

    $ hardworker

Then, in another program, connect to HardWorker and give it a job to do. 
Sample below:

```ruby
class DummyWorker
  attr_accessor :queue

  def initialize
    server_uri = HardWorker::URI
    self.queue = DRbObject.new_with_uri(server_uri)
  end
end

dummy = DummyWorker.new
dummy.queue.push(proc { 2 / 1 })
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/hardworker. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/hardworker/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Hardworker project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/hardworker/blob/master/CODE_OF_CONDUCT.md).
