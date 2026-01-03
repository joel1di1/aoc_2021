require_relative '../../fwk'

lines = File.readlines(File.join(__dir__, 'input5.txt'))

ranges = []

line_index = 0
loop do 
  line = lines[line_index].chomp
  line_index += 1
  break if line.empty?

  left, right = line.split('-').map(&:to_i)
  ranges << (left..right)
end

ingredient_ids = lines[line_index..].map(&:to_i)

fresh_count = ingredient_ids.select { |id| ranges.any? { |range| range.include?(id) } }.count

puts "part 1 : #{fresh_count}"

def ranges_overlap?(a, b)
  a.include?(b.begin) || b.include?(a.begin)
end

def merge_ranges(a, b)
  [a.begin, b.begin].min..[a.end, b.end].max
end

non_overlapping_ranges = []

overlapping_ranges = ranges.clone

until overlapping_ranges.empty?
  range = overlapping_ranges.first
  overlapping_ranges.shift
  index = 0
  while index < overlapping_ranges.size
    other_range = overlapping_ranges[index]
    if ranges_overlap?(range, other_range)
      range = merge_ranges(range, other_range) 
      overlapping_ranges.delete(other_range)
      index = 0
      next 
    end

    index += 1
  end
  non_overlapping_ranges << range
end

puts "part 2 : #{non_overlapping_ranges.map(&:size).sum}"
