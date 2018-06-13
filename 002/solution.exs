# https://projecteuler.net/problem=2
#   Fib sequence sum of even

defmodule Fib do
  def even?(v), do: rem(v, 2) == 0

  # 4 mil limit
  def fib(acc, a, _) when a > 4_000_000 do
    acc
  end

  def fib(acc, a, b) do
    next = a + b
    if even?(next) do
      fib(acc + next, b, next)
    else
      fib(acc, b, next)
    end
  end
end

# 4613732
Fib.fib(0, 1, 2)