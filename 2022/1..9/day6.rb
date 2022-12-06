def find_start_of_packet(datastream)
  # Initialize an array to store the last four characters received
  last_four = []

  # Iterate over the characters in the datastream
  datastream.each_char.with_index do |char, index|
    # Add the current character to the last_four array
    last_four << char

    # If the last_four array has more than four elements, remove the first one
    last_four.shift if last_four.length >   4

    # If the last_four array has four elements and they are all different,
    # return the number of characters processed up to this point
    if last_four.uniq.length == 4
      return index + 1
    end
  end

  # If no start-of-packet marker was found, return 0
  0
end

# Read the input from the file named day6.txt
datastream = File.read("day6.txt")

# Print the result
puts find_start_of_packet(datastream)
