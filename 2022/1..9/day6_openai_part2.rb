# frozen_string_literal: true

def find_marker(input, marker_length)
    i = 0
    while i < input.length - (marker_length - 1)
      if input[i..i+marker_length-1].chars.uniq.length == marker_length
        return i + marker_length
      end
      i += 1
    end
  end
  
  input = File.read('day6.txt').strip
  
  message_marker_length = 14
  message_start_index = find_marker(input, message_marker_length)
  puts "Number of characters processed before the first message marker: #{message_start_index}"
  
  packet_marker_length = 4
  packet_start_index = find_marker(input, packet_marker_length)
  puts "Number of characters processed before the first packet marker: #{packet_start_index}"
  