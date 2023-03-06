require_relative '../fwk'

def f(arr, value)
  return -1 if arr.empty?
  return -1 if value < arr.first
  return arr.last if value > arr.last
  return value if arr[arr.length / 2] == value

  mid = arr.length / 2
  left = arr[0, mid]
  right = arr[mid, arr.length]

  if value > right.first
    f(right, value)
  elsif value < left.last
    f(left, value)
  else
    left.last
  end
end

a = [ 3, 4, 6, 9, 10, 12, 14, 15, 17, 19, 21 ];

assert_eq(-1, f([], 2))
assert_eq(-1, f(a, 2))
assert_eq(21, f(a, 100))
assert_eq(12, f(a, 12))
assert_eq(12, f(a, 13))
assert_eq(19, f(a, 20))

puts "test passed!"