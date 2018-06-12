# BruteForce
defmodule BruteForce do
  # Do not need to check all numbers 1-20, as 20 is divisble by 2
  defstruct limit: 20, check_list: [11, 13, 14, 16, 17, 18, 19, 20]

  def divisible?(a, b) do
    rem(a, b) == 0
  end

  def find(start) when start < 20, do: find(20)

  def find(start) do
    if divisibleUpToTwenty?(start) do
      start
    else
      find(start + 20)
    end
  end

  def divisibleUpToTwenty?(v) do
    divisibleUpToTwentyRec?(v, %BruteForce{}.check_list)
  end

  def divisibleUpToTwentyRec?(v, acc) do
    # How to do this as a function guard?
    try do
      [head | rest] = acc

      if divisible?(v, head) do
        divisibleUpToTwentyRec?(v, rest)
      else
        false
      end
    rescue
      # This is when the checklist runs to 0 elements
      MatchError ->
        true
    end
  end
end

# 232792560
BruteForce.find(0)
