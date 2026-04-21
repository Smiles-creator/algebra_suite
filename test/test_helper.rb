# frozen_string_literal: true

require 'simplecov'

SimpleCov.start do
  root File.expand_path('../..', __dir__)
  
  add_filter '/test/'
  add_filter '/vendor/'
  

  
  add_group 'Boolean Logic', 'lib/algebra_suite/boolean'
  add_group 'Matrix Ops', 'lib/algebra_suite/matrix'
end

require 'minitest/autorun'
require_relative '../lib/algebra_suite'