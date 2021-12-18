# frozen_string_literal: true

require_relative '../../fwk'

class Probe
  attr_reader :x, :y, :x_velocity, :y_velocity, :max

  def self.shoot(x_velocity, y_velocity, target)
    probe = Probe.new(x_velocity, y_velocity, target)
    probe.shoot
  end

  def initialize(x_velocity, y_velocity, target)
    @x = 0
    @y = 0
    @x_velocity = x_velocity
    @y_velocity = y_velocity
    @target = target
    @max = y
  end

  def step
    @x += @x_velocity
    @y += @y_velocity
    @max = @y if @max < @y
    @x_velocity -= 1 if @x_velocity.positive?
    @y_velocity -= 1
  end

  def hit?
    @target[:x].include?(@x) && @target[:y].include?(@y)
  end

  def miss?
    return true if @x < @target[:x].min && @x_velocity.zero?
    return true if @y < @target[:y].min && @y_velocity <= 0
    return true if @x > @target[:x].max

    false
  end

  def shoot
    step until hit? || miss?
    self
  end
end

def possible_starting_x_velocity(target)
  (0..target[:x].max).select do |start_x_vel|
    (0..start_x_vel - 1).any? do |nb_steps|
      x = ((start_x_vel * (start_x_vel + 1)) / 2)
      x -= (((start_x_vel - nb_steps) * (start_x_vel - nb_steps + 1)) / 2)
      target[:x].include? x
    end
  end
end

def hitting_probes(target)
  all_hitting_probes = possible_starting_x_velocity(target).map do |x_vel|
    probes = (-110..110).map { |y_vel| Probe.shoot(x_vel, y_vel, target) }
    probes.select(&:hit?)
  end.flatten

  puts "Max for #{target}: #{all_hitting_probes.map(&:max).max}"
  puts "Count for #{target}: #{all_hitting_probes.count}"
  all_hitting_probes
end

hitting_probes({ x: 20..30, y: -10..-5 })
hitting_probes({ x: 265..287, y: -103..-58 })
