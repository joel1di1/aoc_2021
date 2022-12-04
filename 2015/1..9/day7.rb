# frozen_string_literal: true

require 'byebug'

lines = [
  '123 -> x',
  '456 -> y',
  'x AND y -> d',
  'x OR y -> e',
  'x LSHIFT 2 -> f',
  'y RSHIFT 2 -> g',
  'NOT x -> h',
  'NOT y -> i',
  'f -> a'
]

lines = File.readlines('day7.txt')

@wires = {}
@cache = {}

def final_value(key)
  @cache[key] ||= fetch_final_value(key)
end

def fetch_final_value(key)
  return key if key.instance_of?(Integer)
  return key.to_i if key.instance_of?(String) && key[/^\d+$/]

  val = @wires[key]
  if val.instance_of?(Array)
    val.first.call(*val[1..])
  else
    val
  end
end

lines.each do |line|
  case line
  when /(\w+) AND (\w+) -> (\w+)/
    @wires[Regexp.last_match(3)] = [lambda { |x, y|
                                      final_value(x) & final_value(y)
                                    }, Regexp.last_match(1), Regexp.last_match(2)]
  when /(\w+) OR (\w+) -> (\w+)/
    @wires[Regexp.last_match(3)] = [lambda { |x, y|
                                      final_value(x) | final_value(y)
                                    }, Regexp.last_match(1), Regexp.last_match(2)]
  when /(\w+) LSHIFT (\d+) -> (\w+)/
    @wires[Regexp.last_match(3)] = [->(x, y) { final_value(x) << y }, Regexp.last_match(1), Regexp.last_match(2).to_i]
  when /(\w+) RSHIFT (\d+) -> (\w+)/
    @wires[Regexp.last_match(3)] = [->(x, y) { final_value(x) >> y }, Regexp.last_match(1), Regexp.last_match(2).to_i]
  when /NOT (\w+) -> (\w+)/
    @wires[Regexp.last_match(2)] = [->(x) { 65_535 - final_value(x) }, Regexp.last_match(1)]
  when /^(\w+) -> (\w+)/
    @wires[Regexp.last_match(2)] = [->(x) { final_value(x) }, Regexp.last_match(1)]
  when /^(\d+) -> (\w+)/
    @wires[Regexp.last_match(2)] = Regexp.last_match(1).to_i
  else
    raise line
  end
end

puts "part1: #{final_value('a')}"

@wires['b'] = final_value('a')
@cache = {}

puts "part2: #{final_value('a')}"
