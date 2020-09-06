# https://projecteuler.net/problem=1
#   Multiple of 3 or 5
mult? = &(rem(&1, 3) == 0 or rem(&1, 5) == 0)
x = 1..999 |> Enum.filter(mult?) |> Enum.sum()
IO.puts(x)