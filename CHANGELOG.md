## [Unreleased]

## [0.3.0] - 2021-07-29

- Now there is logging! By default logs to stdout, but you can configure the logger by setting a different one through `Belated.config.logger`. 
## [0.2.0] - 2021-07-25

- Workers now rescue StandardError and keep on working! 
Note that they only rescue StandardError, and as there is no logger yet just pp the inspected error class. 

## [0.1.0] - 2021-07-24

- Gem name changed to Belated!

Below are changes when this gem was named HardWorker:

## [0.0.4] - 2021-07-24

- Rails support!
- Banner (for Belated though...)
- Final release, as the name of this gem is going to change to Belated.
## [0.0.3] - 2021-07-16

- YAML Marshalled queue! So now the queue stays in memory even if restarted. Though kill and term signals still need catching.. that is not done yet.
- Also, now you can use classes! As long as the class has a perform-method.

## [0.0.2] - 2021-07-15

- Bugfix: was requiring byebug.

## [0.0.1] - 2021-07-15

- Initial release! :tada:
  Things are almost working. You can enqueue jobs! That should be more than enough.
  Rails integration to be done soon!
