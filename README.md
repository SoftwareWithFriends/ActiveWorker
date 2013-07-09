ActiveWorker
============
A framework for defining and tracking long-running jobs across a cluster.

Status
------
[![Code Climate](https://codeclimate.com/github/SoftwareWithFriends/ActiveWorker.png)](https://codeclimate.com/github/SoftwareWithFriends/ActiveWorker)
[![Build Status](https://api.travis-ci.org/SoftwareWithFriends/ActiveWorker.png?branch=master)](https://travis-ci.org/SoftwareWithFriends/ActiveWorker)

Core Features:
* Backed by MongoDB/Mongoid for long-term storage of Job Configurations and Events
* Templating to group similar jobs by Scenario
* Hierarchy of Configurations so jobs can launch/own other jobs
* "Root-Object" pattern so all artifacts created by the Job can be organized under a single object for fast/convenient look-ups
* Expansion allows a single configuration to launch multiple instances of the job
* Events keep track of Start/Finish/Termination/Failure of Jobs. FailureEvents record stack-traces.
* Modes allow multiple permutations of fields without having to memorize particular options.

ActiveWorker uses Resque as the underlying job launching platform. Support for Beanstalk has been deprecated.

Purpose
-------
ActiveWorker is designed to support load-testing and performance testing but can be used for any purpose.
The underlying expansion logic supports forking(default) and threading.

Install
-------
```
gem install active_worker
```

Testing
-------
Requires MongoDB and Redis to run tests
bundle exec rake test

