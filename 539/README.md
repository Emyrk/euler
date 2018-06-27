# Observations

Some obsevations trying to solve the problem. Variables:
- n is the length of a list containing elements `1..n`
- P(n) can be found with `Trim.trim_list_n(n)`
- S(n) is the sum of `1..n |> P(n)`
- `p` is the answer of `P(n)`
- `s` is the answer of `S(n)`

## Logarithm

There is definetly something logarithmic about this problem. I first identified this by knowing to calculate P(n), each loop over the set reduces the set by a factor of 2 (`n/2`). This means the number of loops is defined by `floor(log(n)/log(2)) + 1`.

The next interesting bit is how the answers of `P(n)` change as the value of n increases. The answers follow a pattern, until they hit the next power of 2. This means for all `log(n)/log(2) = x`, the answers follow a pattern. The pattern only "breaks" when the next value of x is reached:

```
# The numbers in parentheses is 2^(⌊log2(n)⌋-1) / 2^⌊log2(n)⌋ / 2^(⌊log2(n)⌋+1) <- Truncate all decimals>
#   Which is the range of possible values, and the last number is the range of the next set
#   Also note `n` is jumping by values of 2, as the odd numbers do not matter
n = 120: p = 62  |  log2(n) = 6  (32.0 / 64.0 / 128.0)
n = 122: p = 64  |  log2(n) = 6  (32.0 / 64.0 / 128.0)
n = 124: p = 62  |  log2(n) = 6  (32.0 / 64.0 / 128.0)
n = 126: p = 64  |  log2(n) = 6  (32.0 / 64.0 / 128.0)
n = 128: p = 86  |  log2(n) = 7  (64.0 / 128.0 / 256.0)
n = 130: p = 88  |  log2(n) = 7  (64.0 / 128.0 / 256.0)
n = 132: p = 86  |  log2(n) = 7  (64.0 / 128.0 / 256.0)
```

Another note is that for any odd number, the answer is just `P(n-1)`.

### The range

The notes above define the lower and upper bound of the range of values for `P(n)` (truncate decimals)
- Lower Bound: `2^(⌊log2(n)⌋-1)`
- Upper Bound: `2^⌊log2(n)⌋`

The upper bound is ALWAYS hit, when `n = (2^(⌊log2(n)⌋ + 1)) - 2`

### The pattern

If there is an algorithm to determine the pattern, then the BigO of `P(n)` becomes `O(1)`. This would make `S(n)` be `O(n)`, which might be fast enough? 

If the pattern is identified, not only is `P(n)` become `O(1)`, but we can calculate `P(n)` based off of some previous `P(n-x)`

The pattern for `n` to `n+6` (ignoreing odds), the pattern follows `x`, `y`, `x`, `y`, where `x = y - 2`. This pattern starts where `⌊n/4⌋` is even. On the next  `⌊n/4⌋` being even, the starting number does not seem as easily corrolated to `n-2`. If we could determine the value of `P(x) where x == ⌊n/4⌋ and is even`, then we would have the answer.


**SEE CODE FOR ALL PATTERNS!**

The values for this unlinked number has an interesting property where is starts at some value `< max`, and the max is hit `y` times before we hit the next `n` barrier. Here is the number of times the max value for `P(n)` (based on our bounds) is hit for each range.

```
# ONLY COUNTING EVEN n's, double for all n's
# 2..3 -> 1
# 4..7 -> 1
# 8..15 -> 2
# 16..31 -> 2
# 32..63 -> 4
# 64..127 -> 4
# 128..255 -> 8
# 256..511 -> 8
# 512..1023 -> 16
# 1024..2047 -> 16
# 2048..4095 -> 32
# 4096..8191 -> 32
```

Here are the sums
```
# If you exclude the odds, it is exactly half, but your BigO is also haved
2..3 -> 4
4..7 -> 12
8..15 -> 56
16..31 -> 176
32..63 -> 864
64..127 -> 2752
128..255 -> 13696
256..511 -> 43776
512..1023 -> 218624
1024..2047 -> 699392
2048..4095 -> 3495936
4096..8191 -> 11186176
```

Sums if you only sum every 4th
```
2..3 -> 0  | max: 2.0
4..7 -> 2  | max: 4.0
8..15 -> 12  | max: 8.0
16..31 -> 40  | max: 16.0 <- /4 is 4 off
32..63 -> 208  | max: 32.0
64..127 -> 672  | max: 64.0
128..255 -> 3392  | max: 128.0
256..511 -> 10880  | max: 256.0
512..1023 -> 54528  | max: 512.0 <- /4 is 128 off
1024..2047 -> 174592  | max: 1024.0 <- /4 is 256 off
2048..4095 -> 873472  | max: 2048.0 <- /4 is 512 off
4096..8191 -> 2795520  | max: 4096.0 <- /4 is 1024 off
```


S(n) is the running sum:
```
S(3) = 4  | max: 2.0
S(7) = 16  | max: 4.0
S(15) = 72  | max: 8.0
S(31) = 248  | max: 16.0
S(63) = 1112  | max: 32.0
S(127) = 3864  | max: 64.0
S(255) = 17560  | max: 128.0
S(511) = 61336  | max: 256.0
S(1023) = 279960  | max: 512.0
S(2047) = 979352  | max: 1024.0
S(4095) = 4475288  | max: 2048.0
S(8191) = 15661464  | max: 4096.0
```

Somelists:

```
logn = Enum.to_list(1..12)
four_to_n = [4, 16, 64, 256, 1024, 4096, 16384, 65536, 262144, 1048576, 4194304, 16777216]
sn = [4, 16, 72, 248, 1112, 3864, 17560, 61336, 279960, 979352, 4475288, 15661464]
```


The values double each time for the number of times it hits the max value. 

### Notes

The solution does not require `P(n)` for all `n`, it only requires the sum. There might be a trick to finding the sums, without caluclating each `P(n)`


# Solutions

`Problem.s_pattern(n)` is the current fastest. I could make `Problem.s(n)` just as fast, if not faster by filtering 3/4th of all items in the list, but I didn't feel filtering `n` was leading towards the solution. The pattern matching of `P(n)` to `P(n-1)` helps, but pattern matching `S(n)` to `S(n-1)` would be an even better speedup if there is no forumla for `S(n) = F(n)`