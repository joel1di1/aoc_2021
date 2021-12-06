# frozen_string_literal: true

require 'readline'

def read_passports(file)
  content = File.read(file)
  content.split("\n\n").map { |group| group.split.map { |e| e.split(':') }.to_h }
end

def valid?(passport)
  passport.delete 'cid'
  return false if passport.size != 7

  return false if !passport['byr'][/^\d{4}$/] || passport['byr'].to_i < 1920 || passport['byr'].to_i > 2002
  return false if !passport['iyr'][/^\d{4}$/] || passport['iyr'].to_i < 2010 || passport['iyr'].to_i > 2020
  return false if !passport['eyr'][/^\d{4}$/] || passport['eyr'].to_i < 2020 || passport['eyr'].to_i > 2030
  return false if !passport['hgt'][/^\d+(cm|in)$/]
  return false if passport['hgt'][/^\d+cm$/] && (passport['hgt'].to_i < 150 || passport['hgt'].to_i > 193)
  return false if passport['hgt'][/^\d+in$/] && (passport['hgt'].to_i < 59 || passport['hgt'].to_i > 76)
  return false if !passport['hcl'][/^#(\d|[a-f]){6}$/]
  return false if !%w(amb blu brn gry grn hzl oth).include?(passport['ecl'])
  return false if !passport['pid'][/^\d{9}$/]

  true
end

def count_valid(passports)
  passports.select do |passport|
    v = valid?(passport)
    puts passport unless v
    v
  end.count
end

def process(file)
  puts "#{file}: #{count_valid(read_passports(file))}"
end

process('day4_sample.txt')
process('day4.txt')

