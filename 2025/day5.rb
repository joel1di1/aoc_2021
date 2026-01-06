require_relative '../fwk'

def parse_input(path)
  ranges_block, ids_block = File.read(path).split("\n\n", 2)

  ranges = ranges_block.lines.map do |line|
    left, right = line.split('-').map(&:to_i)
    Range.new(left, right)
  end

  [ranges, ids_block.lines.map(&:to_i)]
end

def merge_overlaps(ranges)
  ranges.sort_by(&:begin).each_with_object([]) do |range, merged|
    if merged.empty?
      merged << range
      next
    end

    last = merged.last
    if last.cover?(range.begin)
      merged[-1] = Range.new(last.begin, [last.end, range.end].max)
    else
      merged << range
    end
  end
end

ranges, ingredient_ids = parse_input(File.join(__dir__, 'input5.txt'))

merged_ranges = merge_overlaps(ranges)
fresh_count = ingredient_ids.count { |id| merged_ranges.any? { |range| range.cover?(id) } }

puts "part 1 : #{fresh_count}"
puts "part 2 : #{merged_ranges.sum(&:size)}"
