
# Node project template using Makefile

This is a template project layout for grumpy old people who want to use Node
that uses a Makefile instead of all the fancy Javascript things. The first
thing you should do is run `./setup.sh`.

## Dependencies

 * python

    Only tested with python2.7

 * npm

 * watchmedo

    Can be installed with `pip install watchmedo`


## Makefile Targets

 * all (default)

    Creates the JS files that can be distributed

 * watch

    This will start `watchmedo` to watch your JS files in node\_modules/app and automatically run `make` to rebuild after saves.

 * server

    Starts a python webserver

