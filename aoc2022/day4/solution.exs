overlaps =
  File.stream!("input.txt")
  |> Enum.to_list()
  |> Enum.map(&String.trim(&1, "\n"))
  |> Enum.map(fn line ->
    [a, b] = String.split(line, ",")
    setA = String.split(a, "-")
    setB = String.split(b, "-")

    [
      Enum.map(setA, &String.to_integer(&1)),
      Enum.map(setB, &String.to_integer(&1))
    ]
  end)
  |> Enum.map(fn [[a, b], [x, y]] ->
    # Truth table
    # +----------+-------+-------+-------+
    # | a-b, x-y | a = x | a < x | a > x |
    # +----------+-------+-------+-------+
    # | b = y    | T     | T     | T     |
    # | b < y    | T     | F     | T     |
    # | b > y    | T     | T     | F     |
    # +----------+-------+-------+-------+

    cond do
      a < x and b < y -> false
      a > x and b > y -> false
      true -> true
    end
  end)
  |> Enum.filter(& &1)
  |> Enum.count()

IO.puts("Pt1: #{overlaps}")

# Part 2
notDisjoint =
  File.stream!("input.txt")
  |> Enum.to_list()
  |> Enum.map(&String.trim(&1, "\n"))
  |> Enum.map(fn line ->
    [a, b] = String.split(line, ",")
    setA = String.split(a, "-")
    setB = String.split(b, "-")

    [
      Enum.map(setA, &String.to_integer(&1)),
      Enum.map(setB, &String.to_integer(&1))
    ]
  end)
  |> Enum.map(fn [[a, b], [x, y]] ->
    !Range.disjoint?(a..b, x..y)
  end)
  |> Enum.filter(& &1)
  |> Enum.count()

IO.puts("Pt2: #{notDisjoint}")
