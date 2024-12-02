require 'byebug'

lines = File.readlines(File.join(__dir__, 'input2.txt')).map(&:strip)

def safe_report_rec?(reports)
  safe = safe_report_inc?(reports)
  return safe if safe == 1

  (0...reports.size).each do |i|
    safe = safe_report_inc?(reports[0...i] + reports[i + 1..])
    return safe if safe == 1
  end

  return 0
end

def safe_report_inc?(reports, jokers = 1)
  return 0 if jokers < 0

  inc = reports[0] <=> reports[1]

  (0...reports.size - 1).each do |i|
    diff = reports[i] - reports[i + 1]
    if !(diff * inc > 0 && diff.abs <= 3)
      return 0
    end
  end
  1
end

safes1 = lines.map { |line| safe_report_inc?(line.split.map(&:to_i)) }.sum
safes2 = lines.map { |line| safe_report_rec?(line.split.map(&:to_i)) }.sum

puts "part1: #{safes1}"
puts "part2: #{safes2}"
