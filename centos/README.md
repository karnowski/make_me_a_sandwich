# Bootstrapping a New Server

## Assumptions

* a 'deploy' user exists
* the 'deploy' user belongs to the 'wheel' group
* the 'deploy' user has passwordless sudo access
* the current directory has both the "bootstrap.sh" script and all related config files

## To bootstrap

Run the following command from the directory where this README lives:

    sudo ./bootstrap.sh
