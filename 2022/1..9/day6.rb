# frozen_string_literal: true

PACKET_MARKER_LENGTH = 4
MESSAGE_MARKER_LENGTH = 14

def find_start_of_marker(datastream, marker_length)
  # Initialize an array to store the last marker_length characters received
  last_chars = []

  # Iterate over the characters in the datastream
  datastream.each_char.with_index do |char, index|
    # Add the current character to the last_chars array
    last_chars << char

    # If the last_chars array has more than marker_length elements, remove the first one
    last_chars.shift if last_chars.length > marker_length

    # If the last_chars array has marker_length elements and they are all different,
    # return the number of characters processed up to this point
    if last_chars.uniq.length == marker_length
      return index + 1
    end
  end

  # If no marker was found, return 0
  0
end

def find_start_of_packet(datastream)
  find_start_of_marker(datastream, PACKET_MARKER_LENGTH)
end

def find_start_of_message(datastream)
  find_start_of_marker(datastream, MESSAGE_MARKER_LENGTH)
end

# Read the input from the file named day6.txt
datastream = File.read("day6.txt")

# Print the results of both parts of the problem
puts "Part 1: #{find_start_of_packet(datastream)}"
puts "Part 2: #{find_start_of_message(datastream)}"
