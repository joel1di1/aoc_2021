# frozen_string_literal: true

require 'readline'
require 'byebug'
require 'set'

def assert_eq(expected, actual, msg: nil)
  raise "Expected #{expected} but received #{actual}" if expected != actual
end

def assert(actual, msg: nil)
  msg ||= "Expected truthy but received #{actual}"
  raise msg unless actual
end
