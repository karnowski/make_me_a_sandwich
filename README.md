# Make Me A Sandwich

A collection of recipes for creating servers suitable for Rails, Node, & Clojure apps.

## Goals

* A simple-to-run, idempotent script for Ubuntu installation and another for CentOS.
* Don't try to abstract away from Ubuntu & CentOS like Chef & Puppet do.
* No requirement of Ruby, so no Capistrano.
* Only require Bash.

## Other Goals, not sure 

* Would really like a way to cd to a Rails/Lein app and run a command to generate a ./bootstrap directory based on the requested arch.  (Don't want to use Rails generators in case of a Clojure/Node app.)
