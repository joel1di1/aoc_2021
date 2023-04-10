# advent of code 2018 
# --- Day 2: Inventory Management System ---

# read input in day2.txt
with open('day2.txt') as f:
    content = f.readlines()

# remove whitespace characters like `\n` at the end of each line
content = [x.strip() for x in content]

# calculate the checksum
twos = 0
threes = 0
for i in content:
    # count the number of times each letter appears
    counts = {}
    for j in i:
        if j in counts:
            counts[j] += 1
        else:
            counts[j] = 1
    # check if any of the counts are 2 or 3
    if 2 in counts.values():
        twos += 1
    if 3 in counts.values():
        threes += 1
print(twos * threes)

