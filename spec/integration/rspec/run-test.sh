#!/bin/bash --login
RAKE="bundle exec rake"
rvm current
rvm use 1.9.3-p484@sauce_ruby --create
bundle install

${RAKE} spec