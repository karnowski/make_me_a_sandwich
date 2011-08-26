# Make Me A Sandwich

A collection of recipes for creating servers suitable for Rails, Node, & Clojure apps.

## Goals

* A simple-to-run, idempotent script for Ubuntu installation and another for CentOS.
* Don't try to abstract away from Ubuntu & CentOS like Chef & Puppet do.
* No requirement of Ruby, so no Capistrano.
* Only require Bash.

## Other Goals, not sure 

* Would really like a way to cd to a Rails/Lein app and run a command to generate a ./bootstrap directory based on the requested arch.  (Don't want to use Rails generators in case of a Clojure/Node app.)

## Design Principles

* each component should be isolated in its own install function
* each install function should be idempotent (safely called again and again)
* always install the development headers in each component's recipe
* this idempotency is to aid debugging and installation and is NOT to be used as a system upgrade mechanism
* but, system updates should be backported to this script

## Thoughts

I'm thinking I might have to use a text-generator like ERB to really make this work.  That would obviously require Ruby.  Hmmm...