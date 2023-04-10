# frozen_string_literal: true

def visible_trees(tree_map)
    rows = tree_map.size
    columns = tree_map[0].size
    visible = 0
  
    # Check the edge trees
    tree_map.each_with_index do |row, i|
      row.each_with_index do |tree, j|
        next if i.between?(1, rows - 2) && j.between?(1, columns - 2) # skip interior trees
  
        visible_from_top = i == 0 || tree_map[0...i].all? { |r| r[j] < tree }
        visible_from_bottom = i == rows - 1 || tree_map[(i + 1)...rows].all? { |r| r[j] < tree }
        visible_from_left = j == 0 || row[0...j].all? { |height| height < tree }
        visible_from_right = j == columns - 1 || row[(j + 1)...columns].all? { |height| height < tree }
  
        visible += 1 if visible_from_top || visible_from_bottom || visible_from_left || visible_from_right
      end
    end
  
    # Check the interior trees
    (1...rows - 1).each do |row|
      (1...columns - 1).each do |col|
        tree_height = tree_map[row][col]
  
        visible_from_top = tree_map[0...row].all? { |r| r[col] < tree_height }
        visible_from_bottom = tree_map[(row + 1)...rows].all? { |r| r[col] < tree_height }
        visible_from_left = tree_map[row][0...col].all? { |height| height < tree_height }
        visible_from_right = tree_map[row][(col + 1)...columns].all? { |height| height < tree_height }
  
        visible += 1 if visible_from_top || visible_from_bottom || visible_from_left || visible_from_right
      end
    end
  
    visible
  end
  
  input_file = File.read('day8.txt')
  tree_map = input_file.lines.map { |line| line.chomp.chars.map(&:to_i) }
  
  puts visible_trees(tree_map)
  