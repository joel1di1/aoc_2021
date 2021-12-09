buses = [29, 41, 601, 23, 13, 17, 19, 463, 37]
init = 1002460

# buses = [7, 13, 59, 31, 19]
# init = 939

max = buses.max

planning = buses.map { |b| [b, []] }.to_h

(0..init + max).each do |i|
  planning.each do |b, _t|
    if (i + init) % b == 0
      puts "res: #{b}, i: #{i} | #{b * i}"
      return
    end
  end
end


