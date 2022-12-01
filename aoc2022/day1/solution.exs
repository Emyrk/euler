reduced =
  File.stream!("input.txt")
  |> Enum.to_list()
  |> Enum.map(&String.trim(&1, "\n"))
  |> Enum.reduce(%{elves: [], current: []}, fn line, acc ->
    if line == "" do
      %{acc | elves: [acc.current | acc.elves], current: []}
    else
      {intval, _} = Integer.parse(line)
      %{acc | current: [intval | acc.current]}
    end
  end)

# To a single list
elves = [reduced.current | reduced.elves]
# IO.inspect(elves)

# Sum them up and sort biggest first.
sums =
  elves
  |> Enum.map(fn elf ->
    Enum.sum(elf)
  end)
  |> Enum.sort()
  |> Enum.reverse()

[best | _] = sums
IO.puts("Best: #{best}")

# Top 3

topThree =
  sums
  |> Enum.slice(0, 3)
  |> Enum.sum()

IO.puts("Top3 Summed: #{topThree}")
