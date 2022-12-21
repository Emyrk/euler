defmodule Mixer do
  def brute_force(order) do
    brute_force(order, 1)
  end

  @spec brute_force(list(integer), integer) :: list(integer)
  def brute_force(order, n) do
    cpy =
      order
      |> Enum.with_index()

    1..n
    |> Enum.reduce(cpy, fn _, acc ->
      order
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {_, key}, acc ->
        shift(acc, key)
      end)
    end)
  end

  def shift(list, key) do
    idx =
      Enum.find_index(list, fn {_, idx} ->
        idx == key
      end)

    {v, orig_idx} = Enum.at(list, idx)

    if v == 0 do
      list
    else
      {{v, orig_idx}, list} = List.pop_at(list, idx)
      # mod = if v >= 0, do: v, else: v - 1
      new_idx = rem(idx + v, length(list))

      new_idx = if new_idx > 0, do: new_idx, else: new_idx - 1

      # IO.inspect([idx, v, length(list), new_idx])
      List.insert_at(list, new_idx, {v, orig_idx})
    end
  end

  def testChain(list, exp) when length(exp) == 0 do
  end

  def testChain(list, [{v, exp} | rest]) do
    found = shift(list, v)

    if found == exp do
      testChain(found, rest)
    else
      IO.inspect(found)
      IO.puts("FAIL for value #{v}")
    end
  end

  def test(l, v, exp) do
    found = shift(l, v)

    if found == exp do
      # IO.puts("OK")
    else
      IO.inspect(found)
      IO.puts("FAIL for value #{v}")
    end
  end

  # @spec add(integer, integer) :: integer
  # def add(a, b) do
  #   a + b
  # end

  def all_tests do
    test(
      [1, -3, 2, 3, -2, 0, 4],
      -3,
      [1, 2, 3, -2, -3, 0, 4]
    )

    test(
      [0, 0, 3, 0, 0, 0],
      3,
      [3, 0, 0, 0, 0, 0]
    )

    test(
      [0, 0, 0, 0, 0, 3],
      3,
      [0, 0, 0, 3, 0, 0]
    )

    test(
      [0, 0, 0, 0, 0, -3],
      -3,
      [0, -3, 0, 0, 0, 0]
    )

    test(
      [0, -4, 0, 0, 0, 0],
      -4,
      [0, 0, -4, 0, 0, 0]
    )

    test(
      [0, 0, 0, 2, 1, 3],
      1,
      [1, 0, 0, 0, 2, 3]
    )

    test(
      [0, 0, 0, 0, 2, 0],
      2,
      [2, 0, 0, 0, 0, 0]
    )

    test(
      [0, -2, 0, 0, 0, 0],
      -2,
      [0, 0, 0, 0, -2, 0]
    )

    testChain(
      [1, 2, -3, 3, -2, 0, 4],
      [
        {1, [2, 1, -3, 3, -2, 0, 4]},
        {2, [1, -3, 2, 3, -2, 0, 4]},
        {-3, [1, 2, 3, -2, -3, 0, 4]},
        {3, [1, 2, -2, -3, 0, 3, 4]},
        {-2, [1, 2, -3, 0, 3, 4, -2]},
        {0, [1, 2, -3, 0, 3, 4, -2]},
        {4, [1, 2, -3, 4, 0, 3, -2]}
      ]
    )
  end
end

defmodule Main do
  def main do
    partOne()
    partTwo()
  end

  def partTwo do
    list =
      readfile("input.txt")
      |> Enum.map(&(&1 * 811_589_153))
      |> Mixer.brute_force(10)
      |> Enum.map(fn {v, _} -> v end)

    coords =
      [1000, 2000, 3000]
      |> Enum.map(fn x ->
        zero = Enum.find_index(list, &(&1 == 0))
        idx = rem(x + zero, length(list))
        Enum.at(list, idx)
      end)
      |> Enum.sum()

    IO.puts("Part 2: #{coords}")
  end

  def partOne do
    list =
      readfile("input.txt")
      |> Mixer.brute_force()
      |> Enum.map(fn {v, _} -> v end)

    # IO.inspect(list)

    coords =
      [1000, 2000, 3000]
      |> Enum.map(fn x ->
        zero = Enum.find_index(list, &(&1 == 0))
        idx = rem(x + zero, length(list))
        Enum.at(list, idx)
      end)
      |> Enum.sum()

    IO.puts("Part 1: #{coords}")
  end

  @spec readfile(charlist) :: list(integer)
  def readfile(file) do
    File.stream!(file)
    |> Enum.to_list()
    |> Enum.map(&String.trim(&1, "\n"))
    |> Enum.map(&String.to_integer(&1))
  end
end

Main.main()

# Mixer.all_tests()
