require_relative '../fwk'
require 'timeout'

Shape = Struct.new(:index, :cells, keyword_init: true)
TIMEOUT_PER_REGION = 30

def parse_input(path)
  lines = File.readlines(path, chomp: true)
  split_idx = lines.index { |line| line =~ /^\d+x\d+:/ }
  shape_lines = lines[0...split_idx].reject(&:empty?)
  region_lines = lines[split_idx..].reject(&:empty?)

  shapes = []
  i = 0
  while i < shape_lines.size
    index = shape_lines[i].to_i
    i += 1
    cells = []
    y = 0
    while i < shape_lines.size && shape_lines[i] !~ /^\d+:$/
      row = shape_lines[i]
      row.chars.each_with_index do |ch, x|
        cells << [x, y] if ch == '#'
      end
      y += 1
      i += 1
    end
    shapes << Shape.new(index: index, cells: cells)
  end

  regions = region_lines.map do |line|
    size_part, counts_part = line.split(':')
    width, height = size_part.split('x').map(&:to_i)
    counts = counts_part.split.map(&:to_i)
    [width, height, counts]
  end

  [shapes.sort_by(&:index), regions]
end

def normalize(cells)
  min_x = cells.map(&:first).min
  min_y = cells.map(&:last).min
  cells.map { |x, y| [x - min_x, y - min_y] }.sort
end

def orientations(cells)
  transforms = []
  coords = cells.map { |x, y| [x, y] }

  4.times do
    transforms << coords
    transforms << coords.map { |x, y| [-x, y] }
    coords = coords.map { |x, y| [y, -x] }
  end

  transforms.map { |coords_set| normalize(coords_set) }.uniq
end

class DLX
  def initialize(primary_cols, total_cols)
    @left = [0]
    @right = [0]
    @up = [0]
    @down = [0]
    @col = [0]
    @size = Array.new(total_cols + 1, 0)

    1.upto(total_cols) do |c|
      @left << c
      @right << c
      @up << c
      @down << c
      @col << c
    end

    last = 0
    1.upto(primary_cols) do |c|
      @right[last] = c
      @left[c] = last
      last = c
    end
    @right[last] = 0
    @left[0] = last
  end

  def add_row(cols)
    nodes = cols.map { |c| new_node(c) }
    nodes.each_with_index do |node, i|
      @left[node] = nodes[i - 1]
      @right[node] = nodes[(i + 1) % nodes.size]
    end
  end

  def solvable?
    search
  end

  private

  def new_node(c)
    idx = @col.size
    @col << c
    @left << idx
    @right << idx
    @up << @up[c]
    @down << c
    @down[@up[c]] = idx
    @up[c] = idx
    @size[c] += 1
    idx
  end

  def cover(c)
    @right[@left[c]] = @right[c]
    @left[@right[c]] = @left[c]
    i = @down[c]
    while i != c
      j = @right[i]
      while j != i
        @down[@up[j]] = @down[j]
        @up[@down[j]] = @up[j]
        @size[@col[j]] -= 1
        j = @right[j]
      end
      i = @down[i]
    end
  end

  def uncover(c)
    i = @up[c]
    while i != c
      j = @left[i]
      while j != i
        @size[@col[j]] += 1
        @down[@up[j]] = j
        @up[@down[j]] = j
        j = @left[j]
      end
      i = @up[i]
    end
    @right[@left[c]] = c
    @left[@right[c]] = c
  end

  def choose_column
    c = @right[0]
    best = c
    best_size = Float::INFINITY
    while c != 0
      if @size[c] < best_size
        best = c
        best_size = @size[c]
        break if best_size <= 1
      end
      c = @right[c]
    end
    best
  end

  def search
    return true if @right[0] == 0

    c = choose_column
    return false if @size[c] == 0

    cover(c)
    r = @down[c]
    while r != c
      j = @right[r]
      while j != r
        cover(@col[j])
        j = @right[j]
      end
      return true if search
      j = @left[r]
      while j != r
        uncover(@col[j])
        j = @left[j]
      end
      r = @down[r]
    end
    uncover(c)
    false
  end
end

def can_pack?(width, height, shapes, counts)
  grid_size = width * height
  total_area = shapes.each_with_index.sum do |shape, idx|
    shape.cells.size * counts[idx]
  end
  return false if total_area > grid_size

  shape_orients = shapes.map { |shape| orientations(shape.cells) }
  placements_by_shape = shapes.map.with_index do |_shape, idx|
    next nil if counts[idx].zero?

    placements = []
    shape_orients[idx].each do |cells|
      max_x = cells.map(&:first).max
      max_y = cells.map(&:last).max
      (0..(width - max_x - 1)).each do |ox|
        (0..(height - max_y - 1)).each do |oy|
          placement = cells.map { |x, y| ((oy + y) * width) + (ox + x) }
          placements << placement
        end
      end
    end
    placements.uniq
  end

  shapes.each_with_index do |_shape, idx|
    next if counts[idx].zero?
    return false if placements_by_shape[idx].nil? || placements_by_shape[idx].empty?
  end

  placement_sizes = placements_by_shape.map { |p| p&.size || 0 }
  piece_shapes = []
  counts.each_with_index do |count, idx|
    count.times { piece_shapes << idx }
  end
  piece_shapes.sort_by! { |idx| placement_sizes[idx] }
  piece_count = piece_shapes.size
  total_cols = piece_count + grid_size
  primary_cols = (total_area == grid_size) ? total_cols : piece_count

  dlx = DLX.new(primary_cols, total_cols)
  piece_shapes.each_with_index do |shape_idx, piece_idx|
    placements_by_shape[shape_idx].sort_by { |cells| cells.first }.each do |cells|
      cols = [piece_idx + 1]
      cells.each { |cell| cols << (piece_count + cell + 1) }
      dlx.add_row(cols)
    end
  end

  dlx.solvable?
end

if $PROGRAM_NAME == __FILE__
  input_path = ARGV[0] || File.join(__dir__, 'input12.txt')
  shapes, regions = parse_input(input_path)

  total = 0
  regions.each_with_index do |(width, height, counts), idx|
    start = Time.now
    warn "region #{idx + 1}/#{regions.size} #{width}x#{height} pieces=#{counts.sum}"
    ok = begin
      Timeout.timeout(TIMEOUT_PER_REGION) do
        can_pack?(width, height, shapes, counts)
      end
    rescue Timeout::Error
      warn "  timeout after #{TIMEOUT_PER_REGION}s"
      false
    end
    elapsed = Time.now - start
    warn "  result=#{ok} time=#{format('%.2f', elapsed)}s"
    total += 1 if ok
  end

  puts "part 1 : #{total}"
end
