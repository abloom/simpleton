## What is Simpleton?

Simpleton is a deployment micro-framework which aims to simplify and improve
the deployment of web applications. In this regard, it is in the same space
as Capistrano, Vlad the Deployer, and other similar tools.

Simpleton is written in Ruby, and relies on existing UNIX command-line tools
(`ssh`, `git`, etc.) to bring out the best of both worlds: a powerful DSL with
testable deployment scripts, and of proven tools that are available
(almost) everywhere.

## Installation

    gem install simpleton

## Example

Here's what a basic deployment script using Simpleton can look like:

    require 'simpleton'
    
    Simpleton.configure do |config|
      config[:hosts] = ["host1", "host2"]
      config[:repository] = "git://github.com/fantastic/awesome.git"
      config[:commit] = "origin/master"
      config[:directory] = "/data/awesome"
    end
    
    Simpleton.use Simpleton::Middleware::GitUpdater
    Simpleton.use Proc.new {'echo "Finished at `date` on the server."'}
    Simpleton.run

The output you'd get would look something like this:

    [host1]< cd /data/awesome && git fetch && git reset --hard origin/master
    [host2]< cd /data/awesome && git fetch && git reset --hard origin/master
    [host1]> HEAD is now at 123abcs This is the best commit ever.
    [host1]< echo "Finished at `date` on the server."
    [host2]> HEAD is now at 123abcs This is the best commit ever.
    [host2]< echo "Finished at `date` on the server."
    [host1]> Finished at Wed Mar  31 04:31:51 UTC 2010 on the server.
    [host2]> Finished at Wed Mar  31 04:31:51 UTC 2010 on the server.

## Design

Simpleton is built around *Middleware* and *Workers*.

### Middleware

A Middleware is an object that responds to `call`, taking as an argument
the Simpleton::Configuration hash. It returns a string, which is a command
that will be executed on a remote host.

For example, when the command from this middleware:

    Proc.new { %Q[echo "The time on the server is `date`"] }

is run, it will echo the current time on a remote host, and when:

    class Something
      def self.call(configuration)
        "git rev-parse #{configuration[:commit]}"
      end
    end

is run, it will lookup the commit-id of the commit to deploy on a remote host.

### Workers

Workers are objects that perform the work for a single host in the
configuration. Each `Simpleton::Worker` constructs a list of commands to run
on its host by calling the Middleware objects in its queue; it then runs
each constructed command, capturing its stdout, stderr and exit status. If any
command fails (returns a non-zero status), the Worker will not run any further
commands and will exit with the failed command's status

Each worker runs in its own process, forked by the Simpleton framework, so it
is isolated from problems that may arise while running commands on the other
hosts.

## Dependencies

* Runtime:
  * `session`
* Development
  * `riot`
  * `rr`

## Thanks

* __Dan Hodos__, for the project name.