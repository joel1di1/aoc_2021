# frozen_string_literal: true

assignement_pairs = File.readlines('day4.txt').map do |line|
  line.split(',').map do |assign_str|
    assignes = assign_str.split('-').map(&:to_i)
    (assignes.first..assignes.last)
  end
end

full_covers = assignement_pairs.map do |left, rigth|
  left.cover?(rigth) || rigth.cover?(left) ? 1 : 0
end.sum

puts "part 1: #{full_covers}"

overlaps = assignement_pairs.map do |left, rigth|
  left.cover?(rigth.first) || rigth.cover?(left.first) ? 1 : 0
end.sum

puts "part 2: #{overlaps}"
