require 'readline'
require 'byebug'
require 'set'

def assert_eq(expected, actual)
  raise "Expected #{expected} but received #{actual}" if expected != actual
end

def assert(actual)
  raise "Expected truthy but received #{actual}" unless actual
end
