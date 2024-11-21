floor =
  File.stream!("input.txt")
  |> Enum.to_list()
  |> Enum.map(&String.trim(&1, "\n"))
  |> Enum.reduce(%{floor: 0}, fn line, acc ->
    line
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.reduce(acc, fn {char, index}, acc ->
      acc =
        case char do
          "(" -> %{acc | floor: acc.floor + 1}
          ")" -> %{acc | floor: acc.floor - 1}
          _ -> acc
        end

      if acc.floor == -1 do
        IO.puts("Basement at: #{index + 1}")
      end

      acc
    end)
  end)

IO.puts("Floor: #{floor.floor}")
