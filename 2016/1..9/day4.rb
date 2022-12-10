# frozen_string_literal: true

# advent of code 2016 day 4 part 1

# --- Day 4: Security Through Obscurity ---
# Finally, you come across an information kiosk with a list of rooms. Of course, the list is encrypted and full of decoy data, but the instructions to decode the list are barely hidden nearby. Better remove the decoy data first.
# Each room consists of an encrypted name (lowercase letters separated by dashes) followed by a dash, a sector ID, and a checksum in square brackets.
# A room is real (not a decoy) if the checksum is the five most common letters in the encrypted name, in order, with ties broken by alphabetization. For example:
# aaaaa-bbb-z-y-x-123[abxyz] is a real room because the most common letters are a (5), b (3), and then a tie between x, y, and z, which are listed alphabetically.
# a-b-c-d-e-f-g-h-987[abcde] is a real room because although the letters are all tied (1 of each), the first five are listed alphabetically.
# not-a-real-room-404[oarel] is a real room.
# totally-real-room-200[decoy] is not.
# Of the real rooms from the list above, the sum of their sector IDs is 1514.
# What is the sum of the sector IDs of the real rooms?

# solve the problem
def solve(input)
  input.each_line.map do |line|
    line.match(/(?<name>.+)-(?<sector_id>\d+)\[(?<checksum>.+)\]/)
  end
    .select do |match|
      checksum = match[:checksum]
      name = match[:name].gsub('-', '')
      checksum == name.chars.group_by(&:itself).map { |k, v| [k, v.size] }.sort_by { |k, v| [-v, k] }.map(&:first).take(5).join
    end
    .map { |match| match[:sector_id].to_i }
    .sum
end

def solve_part2(input)
  input.each_line.select do |line|
    match = line.match(/(?<name>.+)-(?<sector_id>\d+)\[(?<checksum>.+)\]/)
    checksum = match[:checksum]
    name = match[:name].gsub('-', '')
    checksum == name.chars.group_by(&:itself).map { |k, v| [k, v.size] }.sort_by { |k, v| [-v, k] }.map(&:first).take(5).join
end
    .select do |match|
    end
    .map { |match| [ match[:sector_id].to_i] }
end

# input in day4.txt
input = File.read('day4.txt')

puts "part1: #{solve(input)}"

puts "part2: #{solve_part2(input)}"
