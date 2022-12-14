require 'byebug'

$cache = {}

def compare(left, right)
  # puts "left: #{left} - right: #{right}"
  if left.instance_of?(Array) && right.instance_of?(Array)
    if left.empty? && !right.empty?
      return true
    elsif !left.empty? && right.empty?
      return false
    elsif !left.empty? && !right.empty?
      first_res = compare(left[0], right[0])
      return first_res if !first_res.nil?
      return compare(left[1..], right[1..])
    else
      return nil
    end
  elsif left.instance_of?(Integer) && right.instance_of?(Integer)
    return true if left < right
    return false if left > right
    return nil
  elsif right.instance_of?(Array)
    compare([left], right)
  elsif left.instance_of?(Array)
    compare(left, [right])
  end
end

class Packet
  attr_accessor :line

  def initialize(line)
    @line = line
  end

  def <=>(other)
    debugger if !other.instance_of?(Packet)
    compare(@line, other.line)
  end
end

lines = File.readlines('day13.txt').map(&:strip).select{|l| l != ''}
pairs = []
lines.each_slice(2) do |left_str, right_str|
  left = eval(left_str)
  left_packet = Packet.new(left)
  right = eval(right_str)
  right_packet = Packet.new(right)
  pairs << [left_packet, right_packet]
end

results = pairs.map do |left, right|
  res = left <=> right
  # puts "==> #{res}"
  res
end

part1 = results.map.with_index do |res, i|
  res ? i+1 : 0
end.sum
puts "part1: #{part1}"


pairs << [Packet.new([[2]]), Packet.new([[6]])]
packets = pairs.flatten

packets.each do |packet|
  puts "packet: #{packet.line}"
end

sorted = packets.sort{ |a, b| a <=> b ? -1 : 1 }
sorted_s = sorted.map{|p| p.line.to_s}

index_2 = sorted_s.index('[[2]]') + 1
index_6 = sorted_s.index('[[6]]') + 1
puts "sorted: #{index_2 * index_6}"