require_relative '../fwk'

lines = File.readlines(File.join(__dir__, 'input1.txt'))

times_to_zero = 0
dial = 50
lines.each do |line|
  direction = line[0]
  distance = line[1..].to_i

  move = direction == 'L' ? -distance : distance
  dial = (dial + move) % 100

  times_to_zero += 1 if dial == 0
end

puts "part 1: #{times_to_zero}"

times_to_zero = 0
dial = 50
number_of_time_by_zero = 0
lines.each do |line|
  direction = line[0]
  distance = line[1..].to_i
  move = direction == 'L' ? -distance : distance

  number_of_time_by_zero += if dial == 0
                              distance / 100
                            elsif move > 0
                              (dial + distance) / 100
                            elsif dial - distance <= 0
                              1 + ((distance - dial) / 100)
                            else
                              0
                            end

  dial += move
  dial %= 100
end

puts "part 2: #{number_of_time_by_zero}"
