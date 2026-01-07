require 'timeout'

def parse_input(input)
  sections = input.strip.split("\n\n")

  # Parse shapes
  shapes = {}
  shape_section = sections[0..-2].join("\n\n")

  shape_section.split("\n\n").each do |shape_block|
    lines = shape_block.split("\n")
    if lines[0] =~ /^(\d+):$/
      idx = $1.to_i
      grid = lines[1..-1]
      shapes[idx] = parse_shape(grid)
    end
  end

  # Parse regions
  regions = []
  region_lines = sections[-1].split("\n")
  region_lines.each do |line|
    if line =~ /^(\d+)x(\d+):\s*(.+)$/
      width = $1.to_i
      height = $2.to_i
      counts = $3.split.map(&:to_i)
      regions << { width: width, height: height, counts: counts }
    end
  end

  [shapes, regions]
end

def parse_shape(grid)
  # Extract coordinates of # cells
  coords = []
  grid.each_with_index do |row, y|
    row.chars.each_with_index do |cell, x|
      coords << [x, y] if cell == '#'
    end
  end
  normalize(coords)
end

def normalize(coords)
  # Translate shape so minimum x and y are 0
  return [] if coords.empty?

  min_x = coords.map { |x, y| x }.min
  min_y = coords.map { |x, y| y }.min
  coords.map { |x, y| [x - min_x, y - min_y] }.sort
end

def rotate_90(coords)
  # Rotate 90 degrees clockwise: (x, y) -> (y, -x)
  normalize(coords.map { |x, y| [y, -x] })
end

def flip_horizontal(coords)
  # Flip horizontally: (x, y) -> (-x, y)
  normalize(coords.map { |x, y| [-x, y] })
end

def all_transformations(coords)
  # Generate all unique rotations and flips
  transformations = []
  current = coords

  # 4 rotations
  4.times do
    transformations << current
    transformations << flip_horizontal(current)
    current = rotate_90(current)
  end

  transformations.uniq
end

def can_place(grid, shape, x, y, width, height)
  # Check if shape can be placed at position (x, y)
  shape.each do |dx, dy|
    nx, ny = x + dx, y + dy
    return false if nx < 0 || ny < 0 || nx >= width || ny >= height
    return false if grid[ny][nx] != 0
  end
  true
end

def place_shape(grid, shape, x, y, id)
  # Place shape on grid with given id
  shape.each do |dx, dy|
    grid[y + dy][x + dx] = id
  end
end

def remove_shape(grid, shape, x, y)
  # Remove shape from grid
  shape.each do |dx, dy|
    grid[y + dy][x + dx] = 0
  end
end

def solve_region(shapes, width, height, counts)
  # Create list of presents to place
  presents = []
  counts.each_with_index do |count, shape_idx|
    count.times { presents << shape_idx }
  end

  return true if presents.empty?

  # Quick feasibility check: total area
  total_present_area = 0
  presents.each { |idx| total_present_area += shapes[idx].length }
  total_area = width * height
  return false if total_present_area > total_area

  # Sort presents by size (larger first) for better pruning
  shape_sizes = {}
  shapes.each { |idx, coords| shape_sizes[idx] = coords.length }
  presents.sort_by! { |idx| -shape_sizes[idx] }

  # Create empty grid
  grid = Array.new(height) { Array.new(width, 0) }

  # Generate all transformations for each shape
  shape_transforms = {}
  shapes.each do |idx, coords|
    shape_transforms[idx] = all_transformations(coords)
  end

  # Try to place all presents using backtracking
  backtrack(grid, presents, shape_transforms, width, height, 0)
end

def backtrack(grid, presents, shape_transforms, width, height, present_idx)
  return true if present_idx >= presents.length

  shape_idx = presents[present_idx]
  transforms = shape_transforms[shape_idx]

  # Try each transformation
  transforms.each do |shape|
    # Try each position
    (0...height).each do |y|
      (0...width).each do |x|
        if can_place(grid, shape, x, y, width, height)
          place_shape(grid, shape, x, y, present_idx + 1)

          if backtrack(grid, presents, shape_transforms, width, height, present_idx + 1)
            return true
          end

          remove_shape(grid, shape, x, y)
        end
      end
    end
  end

  false
end

def solve(input)
  shapes, regions = parse_input(input)

  count = 0
  regions.each_with_index do |region, idx|
    puts "Checking region #{idx + 1}: #{region[:width]}x#{region[:height]}"

    begin
      result = Timeout.timeout(1) do
        solve_region(shapes, region[:width], region[:height], region[:counts])
      end

      if result
        puts "  ✓ Can fit all presents"
        count += 1
      else
        puts "  ✗ Cannot fit all presents"
      end
    rescue Timeout::Error
      puts "  ✗ Cannot fit all presents (timeout - likely impossible)"
    end
  end

  puts "\nRegions that can fit all presents: #{count}"
  count
end

# Main execution with timeout protection
if __FILE__ == $0
  begin
    Timeout.timeout(600) do  # 10 minutes total
      input = File.read('2025/input12.txt')
      solve(input)
    end
  rescue Timeout::Error
    puts "Program exceeded time limit!"
    exit 1
  rescue Errno::ENOENT
    puts "Error: input12.txt not found in 2025 directory"
    exit 1
  end
end
