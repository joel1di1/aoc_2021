# frozen_string_literal: true

lines = File.readlines(File.join(__dir__, "input11.txt"), chomp: true)

graph = Hash.new { |h, k| h[k] = [] }
lines.each do |line|
  next if line.strip.empty?

  name, outputs = line.split(":", 2)
  name = name.strip
  outputs = outputs.to_s.split.map(&:strip)
  graph[name] = outputs
end

memo = {}

count_paths = lambda do |node|
  return 1 if node == "out"
  return memo[node] if memo.key?(node)

  children = graph[node]
  total = children.sum { |child| count_paths.call(child) }
  memo[node] = total
end

puts "part 1 : #{count_paths.call('you')}"
