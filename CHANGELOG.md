## [Unreleased]

## [0.6.6] - 2021-08-25

- Tests now run agains Ruby 2.6, so relaxing the version constraint. 
- Add client_heartbeat option, so you can define how often you want jobs sent to the Belated server. 
## [0.6.5] - 2021-08-23

- Timezone used inside Belated is all using the server time now, so it's up to the user to take care of that(using `Time.now` instead of `Time.now.utc`)
- Possible to configure host and port.
- No need to call `.start` on the client anymore. 
- Logging some error and warn messages now too, instead of it all being info

## [0.6.4] - 2021-08-22
- Inline jobs for testing!
```ruby
`belated/testing`
Belated::Testing.inline!
```
- Very much inspired by how Sidekiq is doing this. 
- Read more in the testing part of README.md

## [0.6.3] - 2021-08-21

- Needed to have the hash inside the mutex when going over it; otherwise you still the get can't add key into hash during iteration error. Of course.

## [0.6.2] - 2021-08-20

- Use a mutex for the proc_table used by the client. Fixes
`RuntimeError: can't add a new key into hash during iteration (Most recent call first)`, so starting improving thread safety with this fix. 

## [0.6.1] - 2021-08-20

When the client closes and worker has a reference to a proc, a `DRb::ConnError` is raised. Rescueing it and ignoring it.
## [0.6.0] - 2021-08-19

- Only need to keep references on the client side for procs. Not needed for classes, as they are pass-by-value. However, you can only pass procs by reference, so need to keep track of them. They're removed from the client side when they're completed though. 
- The client is now a singleton. This is because it had some overhead when pushing the jobs to dRuby, so I took the approach of also doing that in a background thread. You however do not want more than one client to be running at the same time, so making it a singleton is the best option. Call the `.instance` method to get the singleton and then `.start` to get it started. 

## [0.5.7] - 2021-08-18

- Got errors under heavy load and restarting. Hopefully fixed by rescuing the DRb connection error.
## [0.5.6] - 2021-08-17

- Now the client has a hash table that holds references to the objects you push through it. This is to get by GC, otherwise the objects are collected on clientside, but are still referenced on server side. This means that you do not want to use two instances of Client at the same time. Also, might need to write a way to close the client...
- Should work a bit more safely now! Performance testing 0.5.5 online using a Rails project, it performed horribly, so it should be a bit better now. 
## [0.5.5] - 2021-08-15

- Use SortedSet for future jobs, to avoid having to go through the whole list every few seconds. 


## [0.5.4] - 2021-08-13

- Client was using 100% CPU when it had no connection. (on $5 Digital Ocean droplet) Should be fixed now. 

## [0.5.3] - 2021-08-13

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
