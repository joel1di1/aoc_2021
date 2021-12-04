require 'json'
require 'readline'
require 'securerandom'

class Hash
  def bury *args
    if args.count < 2
      raise ArgumentError.new("2 or more arguments required")
    elsif args.count == 2
      self[args[0]] = args[1]
    else
      arg = args.shift
      self[arg] = {} unless self[arg]
      self[arg].bury(*args) unless args.empty?
    end
    self
  end
end

file_path = 'inputs/json1.txt'
path = 'foo.bar2'

file_content = File.read(file_path)
parsed_json = JSON.parse(file_content)
uuid = SecureRandom.uuid

parsed_json.bury(*path.split('.'), uuid)

compacted_json = JSON.pretty_generate(parsed_json).gsub(/\s/, '')
@file_lines = File.readlines(file_path)

index = 0
loop do
  compact_line = @file_lines[index].gsub(/\s/, '')
  break if !compacted_json.start_with?(compact_line)
  index += 1
  compacted_json = compacted_json[compact_line.length..-1]
end

puts "line is #{index+1}"
