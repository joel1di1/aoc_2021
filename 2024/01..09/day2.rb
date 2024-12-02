require 'byebug'

lines = File.readlines(File.join(__dir__, 'input2.txt')).map(&:strip)

def safe_report_rec?(reports)
  return 1 if safe_report_inc?(reports)

  reports.each_with_index do |_, i|
    return 1 if safe_report_inc?(reports[0...i] + reports[i + 1..])
  end

  0
end

def safe_report_inc?(reports)
  inc = reports[0] <=> reports[1]

  reports.each_cons(2) do |a, b|
    diff = a - b
    return 0 unless diff * inc > 0 && diff.abs <= 3
  end

  1
end

safes1 = lines.sum { |line| safe_report_inc?(line.split.map(&:to_i)) }
safes2 = lines.sum { |line| safe_report_rec?(line.split.map(&:to_i)) }

puts "part1: #{safes1}"
puts "part2: #{safes2}"
