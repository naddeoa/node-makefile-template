#!/usr/bin/make -f

# Hacky makefile thing to get the current working directory, which I am
# considering the project's name by default.
PROJECT_NAME        = $(notdir $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST))))))

# Which port to run the python web server on
SERVER_PORT         = 8888

# The programs that we are using for common javascript things like minification
# and concatonation.
TEST                = ./node_modules/.bin/mocha
MINIFY              = ./node_modules/.bin/minify
CONCAT              = ./node_modules/.bin/browserify --standalone $(REQUIRE)


# The index.js file that declares the public API of the library
INDEXJS             = ./browserify.js

# The names of the artificats produced
FILE                = $(PROJECT_NAME).js
FILE_MIN            = $(PROJECT_NAME).min.js

# The name that require() will use to require this library when used from other
# libraries. Defaults to the name of the project.
REQUIRE             = $(PROJECT_NAME)

# Concat command and file name for use in the browser.
CONCAT_BROWSER      = ./node_modules/.bin/browserify 
FILE_BROWSER        = bundle.js
FILE_MIN_BROWSER    = bundle.min.js

SRC_DIR             = ./node_modules/app
SRC                 = $(SRC_DIR)/*.js

# The external programs that this makefile relies on
DEPENDENCIES        = watchmedo npm python

# This fails the makefile if any of the dependencies are not installed.
# It used the return code of the which command to determine dependencies.
INSTALLED          := $(shell which $(DEPENDENCIES) > /dev/null; echo $$?)
ifneq ($(INSTALLED),0)
$(error "All of the following must be installed: $(DEPENDENCIES)")
endif




# Build the source module
all: $(FILE_MIN)

# Build the source module for the browser
browser: $(FILE_MIN_BROWSER)

# Compile javascript into a single file for browser inclusion
$(FILE): ./node_modules/app/*.js $(INDEXJS)
	$(CONCAT) -r $(INDEXJS):$(REQUIRE) > $(FILE)

# Minify the concatonated source module
$(FILE_MIN): $(FILE)
	$(MINIFY) $(FILE) > $(FILE_MIN)

# Compile a source module for the browser. The automatonjs object
# won't be in the global namespace. You will have to call 
# require("automaotnjs") to get it.
$(FILE_BROWSER): $(FILE)
	$(CONCAT_BROWSER) -r $(INDEXJS):$(REQUIRE) > $(FILE_BROWSER)

# Minify the browser source module
$(FILE_MIN_BROWSER): $(FILE_BROWSER)
	$(MINIFY) $(FILE_BROWSER) > $(FILE_MIN_BROWSER)

# Run the test suite
test:
	$(TEST)

clean:
	-rm $(FILE) $(FILE_MIN) $(FILE_BROWSER) $(FILE_MIN_BROWSER)

# Publish to npm
publish: all
	npm publish .

# Start a python webserver
server:
	python -m SimpleHTTPServer $(SERVER_PORT)

# Which command should be used to watch files and call this makefile when they
# change. If you try to background this and lose track, it appears as a 'python'
# process in top, and takes up around 12.5 mb on OSX.
watch: 
	watchmedo shell-command --recursive --command=$(PWD)/Makefile $(SRC_DIR)

.PHONY: test watch dependencies

