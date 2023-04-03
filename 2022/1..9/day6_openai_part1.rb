# frozen_string_literal: true

input = File.read('day6.txt').strip

i = 0
while i < input.length - 3
  if input[i..i+3].chars.uniq.length == 4
    puts "Number of characters processed before the first marker: #{i + 4}"
    break
  end
  i += 1
end
