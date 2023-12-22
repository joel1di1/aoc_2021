# frozen_string_literal: true

require 'colorize'
require 'readline'
require 'byebug'
require 'set'
require_relative '../../fwk'

class Pulse
  attr_reader :destination, :origin, :level

  def initialize(origin, destination, level)
    @level = level
    @destination = destination
    @origin = origin
  end

  def high?
    @level == :high
  end

  def low?
    @level == :low
  end
end

class FlipFlop
  attr_accessor :state
  attr_reader :destinations, :name

  def initialize(name, destinations)
    @destinations = destinations
    @state = :off
    @name = name
  end

  def receive(pulse)
    return [] if pulse.high?

    flip!
    destinations.map { |destination| Pulse.new(self, destination, on? ? :high : :low) }
  end

  def on?
    state == :on
  end

  def flip!
    @state = if on?
               :off
             else
               :on
             end
  end
end

class Conjunction
  attr_reader :inputs, :destinations, :name

  def initialize(name, destinations)
    @destinations = destinations
    @inputs = {}
    @name = name
  end

  def add_input(input)
    inputs[input] = :low
  end

  def receive(pulse)
    @inputs[pulse.origin] = pulse.level

    destinations.map do |destination|
      Pulse.new(self, destination, @inputs.values.all? { |level| level == :high } ? :low : :high)
    end
  end
end

class Broadcaster
  attr_reader :destinations, :name

  def initialize(destinations)
    @destinations = destinations
    @name = 'broadcaster'
  end

  def receive(pulse)
    destinations.map { |destination| Pulse.new(self, destination, pulse.level) }
  end
end

lines = File.readlines("#{__dir__}/input20.txt", chomp: true)

modules_by_name = {}

lines.each do |line|
  name, dests = line.scan(/(.*) -> (.*)/)[0]

  destinations = dests.split(',').map(&:strip)

  mod = nil
  if name == 'broadcaster'
    mod = Broadcaster.new(destinations)
  elsif name.start_with?('%')
    name = name[1..]
    mod = FlipFlop.new(name, destinations)
  else
    name = name[1..]
    mod = Conjunction.new(name, destinations)
  end

  modules_by_name[name] = mod
end

# debugger

low_pulses = []
high_pulses = []

1000.times do |i|
  init_pulse = Pulse.new(nil, 'broadcaster', :low)

  pulses = [init_pulse]
  puts "\niter #{i+1}"

  until pulses.empty?
    pulse = pulses.shift

    puts "pulse: #{pulse.origin&.name} -#{pulse.level}-> #{pulse.destination}"

    low_pulses << pulse if pulse.low?
    high_pulses << pulse if pulse.high?

    destination = modules_by_name[pulse.destination]

    next if destination.nil?

    new_pulses = destination.receive(pulse)

    pulses += new_pulses if new_pulses.any?
  end
end

puts "low pulses: #{low_pulses.size}"
puts "high pulses: #{high_pulses.size}"
puts "multiply: #{low_pulses.size * high_pulses.size}"

