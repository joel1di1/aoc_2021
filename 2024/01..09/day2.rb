lines = File.readlines(File.join(__dir__, 'input2.txt')).map(&:strip)

safes = lines.map do |line|
  reports = line.split.map(&:to_i)
  safe = true
  inc = reports[0] <=> reports[1]

  (0...reports.size - 1).each do |i|
    diff = reports[i] - reports[i + 1]
    if !(diff * inc > 0 && diff.abs <= 3)
      safe = false
      break
    end
  end

  safe ? 1 : 0
end.sum

puts "part1: #{safes}"
