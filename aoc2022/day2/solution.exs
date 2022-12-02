# A = rock
# B = paper
# C = scissors

# X for rock
# Y for paper
# Z for scissors

# 1 for rock
# 2 for paper
# 3 for scissors

# 0 for lose
# 3 for draw
# 6 for win

points = %{"X" => 1, "Y" => 2, "Z" => 3}

matchPoints = %{
  {"C", "X"} => 6,
  {"A", "Y"} => 6,
  {"B", "Z"} => 6,
  {"A", "X"} => 3,
  {"B", "Y"} => 3,
  {"C", "Z"} => 3,
  {"A", "Z"} => 0,
  {"B", "X"} => 0,
  {"C", "Y"} => 0
}

reduced =
  File.stream!("input.txt")
  |> Enum.to_list()
  |> Enum.map(&String.trim(&1, "\n"))
  |> Enum.map(fn line ->
    [a, b] = String.split(line, " ")
    score = points[b]
    # win/draw/lose
    score + matchPoints[{a, b}]
  end)
  |> Enum.sum()

IO.puts("Pt1 Score: #{reduced}")

# Pt 2
# A = rock
# B = paper
# C = scissors

# X is lose
# Y is draw
# Z is win

# MyThrow
throws = ["A", "B", "C"]
outcomePoints = %{"X" => 0, "Y" => 3, "Z" => 6}
points = %{"A" => 1, "B" => 2, "C" => 3}

# Maps {A, Y} -> A
options =
  for i <- throws,
      j <- ["X", "Y", "Z"],
      do: {i, j}

options =
  options
  |> Enum.reduce(%{}, fn v, acc ->
    {a, b} = v

    throwI = Enum.find_index(throws, &(&1 == a))

    case b do
      "X" ->
        Map.put(acc, {a, b}, Enum.at(throws, rem(throwI - 1 + length(throws), length(throws))))

      "Y" ->
        Map.put(acc, {a, b}, a)

      "Z" ->
        Map.put(acc, {a, b}, Enum.at(throws, rem(throwI + 1, length(throws))))
    end
  end)

reduced =
  File.stream!("input.txt")
  |> Enum.to_list()
  |> Enum.map(&String.trim(&1, "\n"))
  |> Enum.map(fn line ->
    [a, b] = String.split(line, " ")

    myThrow = options[{a, b}]

    score = points[myThrow]
    # win/draw/lose
    score + outcomePoints[b]
  end)
  |> Enum.sum()

IO.puts("Pt2 Score: #{reduced}")
