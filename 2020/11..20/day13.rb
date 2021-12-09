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

# iterator
#
# sol = (num * i) - index_num
# 3 * sol = (num1 * i) - index_num1 + (num2 * i) - index_num2 + (num3 * i) - index_num3
#
# sol = (i * (num1 + num2 + num3) - (index_num1 + index_num2 + index_num3)) / 3

def part2(buses)
  start = buses.compact.reduce(:*)
  (0..).each do |i|
    iter = start - i
    return if iter < 0
    sum = buses.map.with_index do |b, index|
      b ? (iter * b) - index : 0
    end.sum

    if valid?(sum, buses)
      puts "res: #{iter}"
      return iter
    end
  end
  raise 'nope'
end

def sum(n, sum)
  return sum if n.zero?
  n + sum(n - 1, sum)
end

x = nil
sample = [7, 13, x, x, 59, x, 31, 19]

raise '6' unless valid?(6, [3, x, 4])
raise '(3417' unless valid?(3417, [17, x, 13, 19])
raise '(754018' unless valid?(754018, [67, 7, 59, 61])
raise '(779210' unless valid?(779210, [67, x, 7, 59, 61])
raise '(1261476' unless valid?(1261476, [67, 7, x, 59, 61])
raise '(1202161486' unless valid?(1202161486, [1789, 37, 47, 1889])

res = part2([3, x, 4])
raise "6 expected but was #{res}" unless 6 == res

sample_res = part2(sample)
raise "NOT working: #{sample_res} instead of 1068781" unless 1068781 == sample_res

part2 [29, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, 41, x, x, x, x, x, x, x, x, x, 601, x, x, x, x, x, x, x, 23, x, x, x, x, 13, x, x, x, 17, x, 19, x, x, x, x, x, x, x, x, x, x, x, 463, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, x, 37]