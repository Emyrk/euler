# /.iex.exs
# https://projecteuler.net/problem=2
#   Fib sequence sum of even

defmodule Fib do
  # 4 mil limit
  def fib(a, b) when a > 4_000_000 or b > 4_000_000 do
    [a, b]
  end

  def fib(a, b) do
    new = a + b
    [a] ++ fib(b, new)
  end
end

even? = &(rem(&1, 2) == 0)
Fib.fib(1, 2) |> Enum.filter(even?) |> Enum.sum()

# Recursive to find the fib(n)
#   This is slow and only gets 1 value
#   IGNORE THIS
defmodule Fibrec do
  def fib(0), do: 1
  def fib(1), do: 1
  def fib(n), do: fib(n - 1) + fib(n - 2)
end
