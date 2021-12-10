buses = [29, 41, 601, 23, 13, 17, 19, 463, 37]
init = 1002460

# buses = [7, 13, 59, 31, 19]
# init = 939

def part1(init, buses)
  (0..).each do |i|
    buses.each do |b, _t|
      if (i + init) % b == 0
        puts "res: #{b}, i: #{i} | #{b * i}"
        return
      end
    end
  end
end

part1(939, [7, 13, 59, 31, 19])
part1(1002460, [29, 41, 601, 23, 13, 17, 19, 463, 37])

def valid?(i, buses)
  buses.each.with_index do |b, offset|
    return false if b && (i + offset) % b != 0
  end
  true
end

def part2(buses)
  buses_and_pos = buses.compact.sort.reverse.map { |b| [b, buses.index(b)] }
  max, max_index = buses_and_pos[0]
  puts [max]
  (56820000000..).each do |i|
    iter = i * max - max_index

    puts "round: #{i}, tested: #{iter}" if i % 10_000_000 == 0
    valid = buses_and_pos.map do |b, pos|
      break if (iter - pos) % b != 0
    end

    if valid
      puts "Found result!: #{iter}"
      return iter
    end
  end
end
#
# 1_160_000_000
# 100_000_000_000_000
#  31 678 709 999 971
#      52 830 000 000
# 174_289_999_971 / 601
# 6_009_999_971
x = nil
sample = [7, 13, x, x, 59, x, 31, 19]

raise '18' unless valid?(18, [3, x, 4])
raise '(3417' unless valid?(3417, [17, x, 13, 19])
raise '(754018' unless valid?(754018, [67, 7, 59, 61])
raise '(779210' unless valid?(779210, [67, x, 7, 59, 61])
raise '(1261476' unless valid?(1261476, [67, 7, x, 59, 61])
raise '(1202161486' unless valid?(1202161486, [1789, 37, 47, 1889])

# sample_res = part2(sample)
# raise "NOT working: #{sample_res} instead of 1068781" unless 1068781 == sample_res

puts "tests OK"

part2 [29, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, 41, x, x, x, x, x, x, x, x, x, 601, x, x, x, x, x, x, x, 23, x, x, x, x, 13, x, x, x, 17, x, 19, x, x, x, x, x, x, x, x, x, x, x, 463, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, 37]