require_relative '../../fwk'

lines = File.readlines(File.join(__dir__, 'input1.txt'))

times_to_zero = 0
dial = 50
lines.each do |line|
  direction = line[0]
  distance = line[1..].to_i

  move = direction == 'L' ? -distance : distance
  dial = (dial + move) % 100

  puts "direction: #{direction}, distance: #{distance}, dial: #{dial}"
  times_to_zero += 1 if dial == 0
end

puts "part 1: #{times_to_zero}"

times_to_zero = 0
dial = 50
lines.each do |line|
  direction = line[0]
  distance = line[1..].to_i

  move = direction == 'L' ? -distance : distance

  dial += move
  number_of_time_by_zero += if move.positive?
                              dial / 100
                            else
                              (dial / 100) + 1
                            end

  puts "direction: #{direction}, distance: #{distance}, #0 = #{number_of_time_by_zero}"
end
