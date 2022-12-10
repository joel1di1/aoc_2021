require 'byebug'

input = File.read('day7.txt')

# Parse the input and build the filesystem tree
# Parse the input and build the filesystem tree
root = { name: '/', children: [] }
current_dir = root
entries_regex = /(\d+)\s+(\S+)/
input.lines.each do |line|
  if line.start_with?('$')
    # Parse the command
    command, *args = line[1..-1].strip.split(' ')
    case command
    when 'cd'
      if args[0] == '/'
        current_dir = root
      elsif args[0] == '..'
        current_dir = current_dir.fetch(:parent, current_dir)
      else
        current_dir = current_dir[:children].find { |d| d[:name] == args[0] }
      end
    when 'ls'
      # Parse the entries in the directory
      entries = []
      while (match = entries_regex.match(line))
        entries << match.captures
        line = input.lines.next
        break if line.start_with?('$')
      end
      entries.each do |size, name|
        if name.end_with?('.txt', '.dat')
          # This is a file
          current_dir[:children] << { name: name, size: size.to_i }
        else
          # This is a directory
          current_dir[:children] << { name: name, children: [], parent: current_dir }
        end
      end
    end
  end
end

# Calculate the total size of each directory
dirs_to_visit = [root]
dir_sizes = {}
while !dirs_to_visit.empty?
  dir = dirs_to_visit.pop
  total_size = dir[:children].reduce(0) do |sum, child|
    if child[:children]
      dirs_to_visit << child
      sum
    else
      sum + child[:size]
    end
  end
  dir_sizes[dir[:name]] = total_size
end

# Find all directories with a total size of at most 100000
total_size = 0
dir_sizes.each do |name, size|
  if size <= 100000
    total_size += size
  end
end

puts total_size
