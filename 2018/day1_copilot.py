# advent of code 2018
# day 1
# part 1

# read input in day1.txt
with open('day1.txt') as f:
    content = f.readlines()

# remove whitespace characters like `\n` at the end of each line
content = [x.strip() for x in content]

# convert to int
content = [int(x) for x in content]

# sum
print(sum(content))

# part 2

# create a set to store the frequencies
freqs = set()

# set the initial frequency to 0
freq = 0

# loop until we find a duplicate frequency
while True:
    for i in content:
        freq += i
        if freq in freqs:
            print(freq)
            exit()
        freqs.add(freq)

# 57538 !!!


