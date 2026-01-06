require 'timeout'

def parse_line(line)
  # Extract target pattern from [brackets]
  target_match = line.match(/\[(.*?)\]/)
  return nil unless target_match

  target = target_match[1].chars.map { |c| c == '#' ? 1 : 0 }

  # Extract buttons from (parentheses)
  buttons = []
  line.scan(/\(([0-9,]+)\)/).each do |match|
    button = match[0].split(',').map(&:to_i)
    buttons << button
  end

  # Extract joltage requirements from {curly braces}
  joltage_match = line.match(/\{([0-9,]+)\}/)
  joltage = joltage_match ? joltage_match[1].split(',').map(&:to_i) : []

  { target: target, buttons: buttons, joltage: joltage }
end

def solve_machine_part1(target, buttons)
  n_buttons = buttons.length
  n_lights = target.length

  # Try all subsets of buttons, starting from smallest size
  # Since XOR is its own inverse, pressing a button twice = not pressing it
  # So we only need to consider pressing each button 0 or 1 times
  (0..n_buttons).each do |size|
    (0...n_buttons).to_a.combination(size).each do |subset|
      # Calculate the state after pressing these buttons
      state = Array.new(n_lights, 0)
      subset.each do |btn_idx|
        buttons[btn_idx].each { |light| state[light] ^= 1 }
      end

      # Check if we've reached the target
      return size if state == target
    end
  end

  -1  # No solution found
end

def solve_machine_part2(target, buttons)
  require 'tempfile'

  return 0 if target.all?(&:zero?)

  # Create GLPK model file
  lp_file = Tempfile.new(['machine', '.lp'])
  sol_file = Tempfile.new(['solution', '.sol'])

  begin
    # Write LP problem in CPLEX LP format
    lp_file.write("Minimize\n")
    lp_file.write("  obj: " + buttons.length.times.map { |i| "x#{i}" }.join(" + ") + "\n") # rubocop:disable Style/StringConcatenation

    lp_file.write("Subject To\n")
    target.each_with_index do |target_val, counter_idx|
      # Find all buttons that affect this counter
      terms = []
      buttons.each_with_index do |button, btn_idx|
        terms << "x#{btn_idx}" if button.include?(counter_idx)
      end

      next if terms.empty?

      lp_file.write("  c#{counter_idx}: #{terms.join(' + ')} = #{target_val}\n")
    end

    lp_file.write("Bounds\n")
    buttons.length.times do |i|
      lp_file.write("  x#{i} >= 0\n")
    end

    lp_file.write("General\n")
    lp_file.write("  " + buttons.length.times.map { |i| "x#{i}" }.join(" ") + "\n") # rubocop:disable Style/StringConcatenation
    lp_file.write("End\n")

    lp_file.flush

    # write file contents for debugging
    # puts "LP File Contents:\n#{File.read(lp_file.path)}"

    # Solve using GLPK
    `glpsol --lp #{lp_file.path} -o #{sol_file.path} --tmlim 10 2>&1`

    # Parse solution
    if File.exist?(sol_file.path)
      solution_content = File.read(sol_file.path)

      # Check if optimal solution was found
      if (solution_content =~ /Status:\s+INTEGER OPTIMAL/) && (solution_content =~ /Objective:\s+\S+\s+=\s+(\d+)/)
        # Extract objective value (total presses)
        return Regexp.last_match(1).to_i
      end
    end

    -1 # No solution found
  ensure
    lp_file.close
    lp_file.unlink
    sol_file.close
    sol_file.unlink
  end
end

def solve(input, part = 1)
  total_presses = 0

  input.each_line.with_index do |line, idx|
    line = line.strip
    next if line.empty?

    machine = parse_line(line)
    next unless machine

    start_time = Time.now
    presses = if part == 1
                solve_machine_part1(machine[:target], machine[:buttons])
              else
                solve_machine_part2(machine[:joltage], machine[:buttons])
              end
    elapsed = Time.now - start_time

    if presses == -1
      puts "Machine #{idx + 1}: No solution found! (#{elapsed.round(2)}s)"
    else
      puts "Machine #{idx + 1}: #{presses} presses (#{elapsed.round(2)}s)"
      total_presses += presses
    end
  end

  puts "\nTotal button presses: #{total_presses}"
  total_presses
end

# Main execution with timeout protection
if __FILE__ == $PROGRAM_NAME
  begin
    Timeout.timeout(120) do # Increased timeout for Part 2
      input = File.read('2025/input10.txt')

      puts "=== Part 1 ==="
      solve(input, 1)

      puts "\n=== Part 2 ==="
      solve(input, 2)
    end
  rescue Timeout::Error
    puts "Program exceeded time limit!"
    exit 1
  rescue Errno::ENOENT
    puts "Error: input10.txt not found in 2025 directory"
    exit 1
  end
end
