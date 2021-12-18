# frozen_string_literal: true

require_relative '../../fwk'

class Probe
  attr_reader :x, :y, :x_velocity, :y_velocity, :max

  def self.shoot(x_velocity, y_velocity, target)
    probe = Probe.new(x_velocity, y_velocity, target)
    probe.shoot
    probe
  end

  def initialize(x_velocity, y_velocity, target)
    @x = 0
    @y = 0
    @x_init_velocity = x_velocity
    @y_init_velocity = y_velocity
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
    # return true if @x_velocity == 0 && @y_velocity.positive?
    return true if @x < @target[:x].min && @x_velocity == 0
    return true if @y < @target[:y].min && @y_velocity <= 0
    return true if @x > @target[:x].max

    false
  end

  def shoot
    until hit? || miss?
      step
      # puts "new pos: #{x}, #{y}, velocity: (#{x_velocity}, #{y_velocity})"
    end
  end

  def to_s
    "(#{@x_init_velocity}, #{@y_init_velocity}): last pos: (#{@x}, #{@y}), target: #{@target} - hit: #{hit?}, miss: #{miss?}"
  end
end

probe = Probe.shoot(6, 9, { x: 20..30, y: -10..-5 })
assert probe.hit?
assert_eq 45, probe.max

def possible_starting_x_velocity(target)
  (0..target[:x].max).select do |start_x_vel|
    (0..start_x_vel - 1).any? do |nb_steps|
      x = ((start_x_vel * (start_x_vel + 1)) / 2)
      x -= (((start_x_vel - nb_steps) * (start_x_vel - nb_steps + 1)) / 2)
      target[:x].include? x
    end
  end
end

def find_max(target)
  possible_starting_x_velocity = possible_starting_x_velocity(target)

  maxes = possible_starting_x_velocity.map do |x_vel|
    probes = (0..500).map {|y_vel| Probe.shoot(x_vel, y_vel, target)}
    hitting_probes = probes.select(&:hit?)
    max = hitting_probes.map(&:max).max
    max
  end
  maxes.compact.max
end

def count_all(target)
  possible_starting_x_velocity = possible_starting_x_velocity(target)

  all_hitting_probes = possible_starting_x_velocity.map do |x_vel|
    probes = (0..1000).map {|y_vel| Probe.shoot(x_vel, y_vel, target)}
    probes.select(&:hit?)
  end

  all_hitting_probes = all_hitting_probes.flatten
  all_hitting_probes.sum
end
#
# assert_eq 45, find_max({ x: 20..30, y: -10..-5 })
# puts "max: #{find_max({ x: 265..287, y: -103..-58 })}"
puts "count: #{count_all({ x: 265..287, y: -103..-58 })}"

#
# def steps(x_init_vel, y_init_vel, nb_steps)
#   y = (0..nb_steps - 1).map { |i| y_init_vel - i }.sum
#   x = ((x_init_vel * (x_init_vel + 1)) / 2)
#   x -= (((x_init_vel - nb_steps) * (x_init_vel - nb_steps + 1)) / 2) if x_init_vel > nb_steps
#   x = [0, x].max
#   [x, y, [x_init_vel - nb_steps, 0].max, y - nb_steps]
# end
#
# def hit?(probe, target)
#   probe_x = probe[0]
#   probe_y = probe[1]
#   max = -Float::INFINITY
#   (1..).each do |steps|
#     x, y, x_vel_res, y_vel_res = steps(probe_x, probe_y, steps)
#     max = [max, y].max
#     return max if target[:x].include?(x) && target[:y].include?(y)
#
#     return nil if x > target[:x].max && x_vel_res == 0
#     return nil if x < target[:x].min && x_vel_res == 0
#     return nil if y < target[:y].min && y_vel_res <= 0
#   end
# end
#
# sample_target = { x: 20..30, y: -10..-5 }
#
# assert hit?([7, 2], sample_target)
# assert hit?([6, 3], sample_target)
# assert hit?([9, 0], sample_target)
# assert_eq 45, hit?([6, 9], sample_target)
# assert !hit?([9, 7], sample_target)
# assert !hit?([1, 2], sample_target)
# assert !hit?([17, -4], sample_target)
#
# def find_max2(target)
#   (1..target[:x].max).map do |x_vel|
#     (target[:y].min..1000).map do |y_vel|
#       hit?([x_vel, y_vel], target)
#     end
#   end.flatten.compact.max
# end
#
# assert_eq 45, find_max2(sample_target)
#
# puts 'OK'
