# Recursive to find the fib(n)
#   This is slow and only gets 1 value
#   IGNORE THIS
defmodule Fibrec do
  def fib(0), do: 1
  def fib(1), do: 1
  def fib(n), do: fib(n - 1) + fib(n - 2)
end
