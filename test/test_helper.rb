# frozen_string_literal: true
require 'bundler/setup' 
require 'simplecov'
SimpleCov.start do
  add_filter '/test/'
  add_filter '/vendor/'
  
  add_filter '/Rakefile'
  add_filter '/Gemfile'
  add_group 'Source Files', 'lib/'
  

 # minimum_coverage 80
end
$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "algebra_suite"

require "minitest/autorun"