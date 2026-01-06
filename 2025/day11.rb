require_relative '../fwk'
require 'matrix'
require 'glpk'

class Path
  attr_accessor :devices, :device_set

  def initialize(devices)
    self.devices = devices
    self.device_set = devices.to_set
  end

  def append(device)
    Path.new(devices + [device])
  end

  def cycle?
    devices.length != device_set.length
  end

  def end?
    devices.last == 'out'
  end

  def next_paths(devices_map)
    last_device = devices.last
    neighbors = devices_map[last_device] || []
    neighbors.map { |neighbor| append(neighbor) }
  end
end


lines = File.readlines(File.join(__dir__, 'input11.txt'), chomp: true)

devices_map = {}
lines.each do |line|
  device, neighbors_str = line.split(':')
  neighbors = neighbors_str.split.map(&:strip)
  devices_map[device] = neighbors
end

paths = [Path.new(['you'])]
ended_paths = []
until paths.empty?
  path = paths.pop

  next if path.cycle?

  if path.end?
    ended_paths << path
    next
  end

  paths += path.next_paths(devices_map)
end

puts "part 1 : #{ended_paths.count}"

# paths = [Path.new(['svr'])]
# ended_paths = []
# until paths.empty?
#   path = paths.pop

#   next if path.cycle?

#   if path.end?
#     ended_paths << path
#     next
#   end

#   paths += path.next_paths(devices_map)
# end

puts "part 2 : #{ended_paths.count}"

