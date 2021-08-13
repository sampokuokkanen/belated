## [Unreleased]


## [0.5.3] - 2021-08-14

- A bit less looping - better performance.
## [0.5.2] - 2021-08-13

- An error with shutdown handling was fixed.

## [0.5.1] - 2021-08-12

- Requiring byebug in bin file. 😮

## [0.5.0] - 2021-08-011

- Job retries! The jobs now have ids, so you can follow the job and it's retries from the log. 
- Quite a lot has changed internally, so if you were not using the Belated::Queue class to enqueue your jobs, you will need to update your code.

## [0.4.4] - 2021-08-07

- Now if you pass something with a syntax error in it as a job, it should not bring down the whole app! 

## [0.4.3] - 2021-08-06

- Client now starts the banker thread to execute jobs that were enqueued when there was no connection to Belated only if necessary. 
## [0.4.2] - 2021-08-05

- Client also handles no connection, now it saves jobs to a bank and adds them to the queue once it has a connection.  
## [0.4.1] - 2021-08-05

- Now handles saving future jobs too! So if you have a job enqueued for tomorrow, and restart Belated, it should still be enqueued. 

## [0.4.0] - 2021-08-03

- Now you can enqueue jobs to be done at a later time. Just pass an `at:` keyword param to the client. 
- Does not save the jobs when you quit. 

## [0.3.3] - 2021-08-01

- Shutdown trapped signal thread, make sure :shutdown is not recorded as a job. 

## [0.3.2] - 2021-07-31

- Trap INT and TERM, so now the shutdown is a little bit more graceful. 

## [0.3.1] - 2021-07-29

- Remove dummy app from gem... size should go down quite a bit. 

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
