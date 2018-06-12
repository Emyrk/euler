# https://projecteuler.net/problem=2
#   Fib sequence sum of even

defmodule Fib do
  # 4 mil limit
  def fib(acc, a, b) when a > 4_000_000 or b > 4_000_000 do
    acc ++ [a]
  end

  def fib(acc, a, b) do
    fib(acc ++ [a], b, a + b)
  end
end

even? = &(rem(&1, 2) == 0)
# 4613732
Fib.fib([], 1, 2) |> Enum.filter(even?) |> Enum.sum()
