require 'byebug'
require 'set'

cubes = File.readlines('day18.txt').each_with_object({}) do |line, cubes|
  cube = line.strip.split(',').map(&:to_i)
  cubes[cube] = cubes
end

def neighbors(cube)
  x, y, z = cube
  [[-1, 0, 0 ], [0, -1, 0], [0, 0, -1], 
   [1, 0, 0], [0, 1, 0], [0, 0, 1]].map do |dx, dy, dz|
      [x + dx, y + dy, z + dz]
  end
end

def count_free_sides(cubes, cube)
  neighbors(cube).count { |neighbor| cubes[neighbor].nil? }
end

free_sides = cubes.map do |cube, _| 
  count_free_sides(cubes, cube)
end.sum

puts "Part 1: #{free_sides}"

# part 2

# find one exterior cube
# find max x
min_x = cubes.keys.map(&:first).min

# face is defined by a cube and a direction

faces_to_inspect = Set.new(cubes.keys.select { |cube| cube.first == min_x }.map { |cube| [cube, :west] })

# remember inspected cubes
inspected_faces = Set.new

faces_to_check = {
  north: [ 
    [{offset: [0, 1, 1], face: :front}, {offset: [0, 0 , 1], face: :north}, {offset: [0, 0, 0],  face: :back}], # back edge faces
    [{offset: [0, 1, -1], face: :back}, {offset: [0, 0 , -1], face: :north}, {offset: [0, 0, 0],  face: :front}], # front edge faces
    [{offset: [-1, 1, 0], face: :east}, {offset: [-1, 0 , 0], face: :north}, {offset: [0, 0, 0],  face: :west}], # west edge faces
    [{offset: [1, 1, 0], face: :west}, {offset: [1, 0 , 0], face: :north}, {offset: [0, 0, 0],  face: :east}], # east edge faces
  ],
  south: [
    [{offset: [0, -1, 1], face: :front}, {offset: [0, 0 , 1], face: :south}, {offset: [0, 0, 0],  face: :back}], # back edge faces
    [{offset: [0, -1, -1], face: :back}, {offset: [0, 0 , -1], face: :south}, {offset: [0, 0, 0],  face: :front}], # front edge faces
    [{offset: [-1, -1, 0], face: :east}, {offset: [-1, 0 , 0], face: :south}, {offset: [0, 0, 0],  face: :west}], # west edge faces
    [{offset: [1, -1, 0], face: :west}, {offset: [1, 0 , 0], face: :south}, {offset: [0, 0, 0],  face: :east}], # east edge faces
  ],
  east: [
    [{offset: [1, 0, 1], face: :front}, {offset: [0 , 0, 1], face: :east}, {offset: [0, 0, 0],  face: :back}], # back edge faces
    [{offset: [1, 0, -1], face: :back}, {offset: [0 , 0, -1], face: :east}, {offset: [0, 0, 0],  face: :front}], # front edge faces
    [{offset: [1, 1, 0], face: :south}, {offset: [0 , 1, 0], face: :east}, {offset: [0, 0, 0],  face: :north}], # north edge faces
    [{offset: [1, -1, 0], face: :north}, {offset: [0 , -1, 0], face: :east}, {offset: [0, 0, 0],  face: :south}], # south edge faces
  ],
  west: [
    [{offset: [-1, 0, 1], face: :front}, {offset: [0 , 0, 1], face: :west}, {offset: [0, 0, 0],  face: :back}], # back edge faces
    [{offset: [-1, 0, -1], face: :back}, {offset: [0 , 0, -1], face: :west}, {offset: [0, 0, 0],  face: :front}], # front edge faces
    [{offset: [-1, 1, 0], face: :south}, {offset: [0 , 1, 0], face: :west}, {offset: [0, 0, 0],  face: :north}], # north edge faces
    [{offset: [-1, -1, 0], face: :north}, {offset: [0 , -1, 0], face: :west}, {offset: [0, 0, 0],  face: :south}], # south edge faces
  ],
  front: [
    [{offset: [-1, 0, -1], face: :east}, {offset: [-1 , 0, 0], face: :front}, {offset: [0, 0, 0],  face: :west}], # west edge faces
    [{offset: [1, 0, -1], face: :west}, {offset: [1 , 0, 0], face: :front}, {offset: [0, 0, 0],  face: :east}], # east edge faces
    [{offset: [0, 1, -1], face: :south}, {offset: [0 , 1, 0], face: :front}, {offset: [0, 0, 0],  face: :north}], # north edge faces
    [{offset: [0, -1, -1], face: :north}, {offset: [0 , -1, 0], face: :front}, {offset: [0, 0, 0],  face: :south}], # south edge faces
  ],
  back: [
    [{offset: [-1, 0, 1], face: :east}, {offset: [-1 , 0, 0], face: :back}, {offset: [0, 0, 0],  face: :west}], # west edge faces
    [{offset: [1, 0, 1], face: :west}, {offset: [1 , 0, 0], face: :back}, {offset: [0, 0, 0],  face: :east}], # east edge faces
    [{offset: [0, 1, 1], face: :south}, {offset: [0 , 1, 0], face: :back}, {offset: [0, 0, 0],  face: :north}], # north edge faces
    [{offset: [0, -1, 1], face: :north}, {offset: [0 , -1, 0], face: :back}, {offset: [0, 0, 0],  face: :south}], # south edge faces
  ]
}

exterior_faces = Set.new

# print max number of faces to inspect
puts "Max number of faces to inspect: #{cubes.size * 6}"

until faces_to_inspect.empty?
  # take one cube
  current_cube, current_face = faces_to_inspect.first
  faces_to_inspect.delete([current_cube, current_face])
  next if inspected_faces.include?("#{current_cube},#{current_face}")

  puts "#{inspected_faces.size} Inspecting #{current_cube},#{current_face} , #{faces_to_inspect.size} faces to inspect, #{exterior_faces.count} exterior faces"
  inspected_faces << "#{current_cube},#{current_face}"
  exterior_faces << "#{current_cube},#{current_face}"

  # for each direction, find next face to inspect
  faces_to_check[current_face].each do |directions_to_check|
    # remember directions are like: 
    # [{offset: [0, 1, 1], face: :front}, {offset: [0, 0 , 1], face: :north}, {offset: [0, 0, 0],  face: :back}]
    puts "  Checking #{directions_to_check}"
    next_cube = nil
    next_face = nil
    directions_to_check.each do |next_to_check| 
      coords = current_cube.zip(next_to_check[:offset]).map(&:sum)
      if cubes[coords]
        next_cube = coords
        next_face = next_to_check[:face]
        break
      end
    end
    # add next face to inspect
    if inspected_faces.include?("#{next_cube},#{next_face}")
      puts "    Already inspected #{next_cube},#{next_face}"
    else
      puts "    Adding #{next_cube},#{next_face} to faces to inspect"
      faces_to_inspect << [next_cube, next_face]
    end
  end
end

puts "Part 2: #{exterior_faces.count}"

# puts "exterior_faces: #{exterior_faces.to_a.sort.join("\n")}"