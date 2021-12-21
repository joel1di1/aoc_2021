# frozen_string_literal: true

require_relative '../../fwk'

def next_packet(msg)
  packet = { sub_packets: [] }
  packet[:version] = msg.shift(3).join.to_i(2)
  packet[:type_id] = msg.shift(3).join.to_i(2)

  case packet[:type_id]
  when 4
    num_str = String.new
    while msg.shift == 1
      num_str.concat msg.shift(4).join
    end
    num_str.concat msg.shift(4).join
    packet[:value] = num_str.to_i(2)
  else
    packet[:length_type_id] = msg.shift
    case packet[:length_type_id]
    when 0
      sub_packets_length = msg.shift(15).join.to_i(2)
      sub_msg = msg.shift(sub_packets_length)
      until sub_msg.empty?
        packet[:sub_packets] << next_packet(sub_msg)
      end
    when 1
      sub_packets_number = msg.shift(11).join.to_i(2)
      packet[:sub_packets] = (0..sub_packets_number - 1).map do ||
        next_packet(msg)
      end
    else
      raise "Unknown length type id : #{packet[:length_type_id]}"
    end
  end

  packet
end

def hex_to_chars(str)
  str.strip.chars.map { |c| c.hex.to_s(2).rjust(4, '0') }.join.chars.map(&:to_i)
end

def tests
  assert_eq 2021, next_packet(hex_to_chars('D2FE28'))[:value]

  packet_2 = next_packet(hex_to_chars('38006F45291200'))
  assert_eq 2, packet_2[:sub_packets].size
  assert_eq 10, packet_2[:sub_packets][0][:value]
  assert_eq 20, packet_2[:sub_packets][1][:value]

  packet_3 = next_packet(hex_to_chars('EE00D40C823060'))
  assert_eq 3, packet_3[:sub_packets].size
  assert_eq 1, packet_3[:sub_packets][0][:value]
  assert_eq 2, packet_3[:sub_packets][1][:value]
  assert_eq 3, packet_3[:sub_packets][2][:value]

  puts "tests OK\n"
end

def extract_versions(packet, versions = [])
  versions << packet[:version]
  packet[:sub_packets].each { |p| extract_versions(p, versions) }
  versions
end

def compute(packet)
  return packet[:value] if packet[:type_id] == 4

  values = packet[:sub_packets].map { |p| compute(p) }
  case packet[:type_id]
  when 0
    values.sum
  when 1
    values.reduce(:*)
  when 2
    values.min
  when 3
    values.max
  when 5
    values[0] > values[1] ? 1 : 0
  when 6
    values[0] < values[1] ? 1 : 0
  when 7
    values[0] == values[1] ? 1 : 0
  end
end

tests

content = File.read('day16.txt')
packet = next_packet(hex_to_chars(content))

puts extract_versions(packet).sum
puts compute(packet)

#
# decode content
# puts content.join