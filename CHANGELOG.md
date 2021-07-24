## [Unreleased]

Rails support!
Need a better way to find Rails config, going to release 0.1.0 after that.
Going to change the name of the gem to something a bit more original than HardWorker. 
(HardWorker is already in use in Sidekiq documentation) 
## [0.0.1] - 2021-07-15

- Initial release! :tada:
Things are almost working. You can enqueue jobs! That should be more than enough. 
  Rails integration to be done soon!

## [0.0.2] - 2021-07-15

- Bugfix: was requiring byebug. 

## [0.0.3] - 2021-07-16

- YAML Marshalled queue! So now the queue stays in memory even if restarted. Though kill and term signals still need catching.. that is not done yet. 
- Also, now you can use classes! As long as the class has a perform-method. 

## [0.0.4] - 2021-07-24

- Rails support!
- Banner (for Belated though...)
- Final release, as the name of this gem is going to change to Belated. 