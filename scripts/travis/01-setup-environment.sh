#!/usr/bin/env bash

## Setup environment
# add composer's global bin directory to the path
# see: https://github.com/drush-ops/drush#install---composer
export THUNDER_DIST_DIR=`echo $(pwd)`
export TEST_DIR=`echo ${THUNDER_DIST_DIR}"/../test-dir"`
export PATH="$TEST_DIR/bin:$HOME/.composer/vendor/bin:$PATH"
export TEST_INSTALLER="false"

# For daily cron runs, current version from Drupal will be installed
# and after that update will be executed and tested
if [[ ${TRAVIS_EVENT_TYPE} == "cron" ]]; then
    TEST_UPDATE="true"
else
    TEST_UPDATE=""
fi

export TEST_UPDATE;

# base path for update tests
export UPDATE_BASE_PATH=${TEST_DIR}-update-base

# Set version of imagick
export PHP_IMAGICK_VERSION="3.4.3"

# Set version for Yaml PHP library (for PHP 5.6 -> Yaml version 1.x will be used)
if [[ $TRAVIS_PHP_VERSION = '5.6' ]] ; then
  PHP_YAML_VERSION="1.3.1"
else
  PHP_YAML_VERSION="2.0.2"
fi;
export PHP_YAML_VERSION

# Set a default install method if none set.
if [[ ${INSTALL_METHOD} == "" ]]; then
  export INSTALL_METHOD=composer
fi;

# Pull requests, that only contain text file changes should be skipped
if [[ ${TRAVIS_PULL_REQUEST} == true ]]; then
    SKIP_TEST=true
    for file in $( git diff --name-only ${TRAVIS_BRANCH}); do
        if [[ (${file} != *.txt) &&  (${file} != *.md) ]]; then
            SKIP_TEST=false
        fi
    done
else
    SKIP_TEST=false
fi
export ${SKIP_TEST}

echo ${SKIP_TEST}

# Manual overrides of environment variables by commit messages. To override a variable add something like this to
# your commit message:
# git commit -m="Your commit message [TEST_UPDATE=true]"
#
# To override multiple variables us something like this:
# git commit -m="Your other commit message [TEST_UPDATE=true|INSTALL_METHOD=composer]"
if [[ ${TRAVIS_EVENT_TYPE} == "pull_request" ]]; then
    # These are the variables, that are allowed to be overridden
    ALLOWED_VARIABLES=("TEST_UPDATE" "INSTALL_METHOD" "TEST_INSTALLER" "SAUCE_LABS_ENABLED")
    COMMIT_MESSAGE=$(git log --no-merges -1 --pretty="%B")
    for VARIABLE_NAME in "${ALLOWED_VARIABLES[@]}"
    do
        VALUE=$(echo $COMMIT_MESSAGE | perl -lne "/[|\[]$VARIABLE_NAME=(.+?)[|\]]/ && print \$1")
        if [[ $VALUE ]]; then
            export $VARIABLE_NAME=$VALUE
        fi
    done
fi
# Do not place any code behind this line.
