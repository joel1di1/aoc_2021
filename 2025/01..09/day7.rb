require_relative '../../fwk'

def parse_grid(path)
  rows = File.readlines(path, chomp: true)
  height = rows.size
  width = rows.first.size

  grid = {}
  rows.each_with_index do |row, y|
    row.chars.each_with_index do |char, x|
      grid[[x, y]] = char
    end
  end

  [grid, width, height]
end 

def down_all!(grid, beams)
  new_beams = Set.new
  splits = 0
  beams.each do |beam|
    down_pos = [beam[0], beam[1] + 1]
    case grid[down_pos]
    when '.'
      new_beams << down_pos unless grid[down_pos].nil?
    when '^'
      splits += 1
      left = [down_pos[0] - 1, down_pos[1]]
      right = [down_pos[0] + 1, down_pos[1]]
      new_beams << left unless grid[left].nil?
      new_beams << right unless grid[right].nil?
    end
  end
  [new_beams, splits]
end

grid, width, height = parse_grid(File.join(__dir__, 'input7.txt'))


beams = Set.new([grid.key('S')])
total_splits = 0

until beams.empty?
  beams, splits = down_all!(grid, beams)  
  total_splits += splits
end

puts "part 1 : #{total_splits}"

def timeline_advance(grid, timelines)
  new_timelines = {}
  timelines.each do |last_pos, nb_timelines|
    down_pos = [last_pos[0], last_pos[1] + 1]

    case grid[down_pos]
    when '.'
      new_timelines[down_pos] = nb_timelines + (new_timelines[down_pos] || 0)
    when '^'
      left = [down_pos[0] - 1, down_pos[1]]
      right = [down_pos[0] + 1, down_pos[1]]
      new_timelines[left] = nb_timelines + (new_timelines[left] || 0)
      new_timelines[right] = nb_timelines + (new_timelines[right] || 0)
    end
  end
  new_timelines
end

timelines = {}
timelines[grid.key('S')] = 1

(height-1).times do 
  timelines = timeline_advance(grid, timelines)  
end

puts "part 2 : #{timelines.values.sum}"
