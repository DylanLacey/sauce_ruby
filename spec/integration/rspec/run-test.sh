#!/bin/bash --login
RAKE="bundle exec rake"
rvm current
bundle install

${RAKE} spec