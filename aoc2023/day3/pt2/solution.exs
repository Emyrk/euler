# Faster indexing into arrays
# https://hexdocs.pm/arrays/Arrays.html#module-using-arrays
Mix.install([:arrays])

defmodule Parse do
  def parse_row(row) do
    acc =
      row
      |> Enum.with_index()
      |> Enum.reduce(%{cur: [], found: []}, fn {c, i}, acc ->
        # IO.puts("#{inspect(c)}, #{inspect(acc)}, #{c >= ?0 and c <= ?9}")

        cond do
          c >= ?0 and c <= ?9 ->
            # If we found a number, add to the tracking.
            %{cur: acc.cur ++ [c], found: acc.found}

          true ->
            # Possible end of number. Reset the current tracking.
            # Parse the number in the tracking and add it.

            %{cur: [], found: acc.found ++ parse_tracking(acc.cur, i)}
        end
      end)

    acc.found ++ parse_tracking(acc.cur, Arrays.size(row))
  end

  def parse_tracking(track, _) when length(track) == 0 do
    []
  end

  def parse_tracking(track, i) do
    [
      %{
        start: i - length(track),
        value: String.to_integer(to_string(track))
      }
    ]
  end
end

grid =
  File.stream!("input.txt")
  |> Enum.to_list()
  |> Enum.map(&String.trim(&1, "\n"))
  |> Enum.map(&String.to_charlist/1)
  |> Enum.map(&Arrays.new/1)
  |> Enum.into(Arrays.new())

rows = Arrays.size(grid)
cols = Arrays.size(grid[0])
IO.puts("Rows: #{rows}, Cols: #{cols}")

gears =
  0..(rows - 1)
  |> Enum.reduce([], fn y, acc ->
    # IO.puts("-- #{inspect(Arrays.to_list(grid[y]))}")

    0..(cols - 1)
    |> Enum.reduce(acc, fn x, acc ->
      c = grid[y][x]

      cond do
        c == ?* -> [{x, y} | acc]
        true -> acc
      end
    end)
  end)

# Numbers only exist on rows
numbers =
  grid
  # |> Arrays.to_list()
  # |> Enum.each(&IO.puts("RRow: #{inspect(&1)}"))
  |> Enum.map(&Parse.parse_row/1)

# IO.puts("Gears: #{inspect(gears)}")

gear_ratios =
  gears
  # Map to a list of adjacent squares
  |> Enum.map(fn {x, y} ->
    [
      {x, y},
      {x - 1, y - 1},
      {x, y - 1},
      {x + 1, y - 1},
      {x - 1, y},
      {x + 1, y},
      {x - 1, y + 1},
      {x, y + 1},
      {x + 1, y + 1}
    ]
  end)
  # For each gear, find all numbers that are adjacent to it
  |> Enum.map(fn squares ->
    numbers
    |> Enum.with_index()
    |> Enum.map(fn {row, row_y} ->
      row
      |> Enum.filter(fn %{start: start, value: value} ->
        numEnd =
          start + length(String.to_charlist(to_string(value))) - 1

        is_part =
          squares
          |> Enum.any?(fn {x, y} -> row_y == y and x >= start and x <= numEnd end)

        is_part
      end)
      |> Enum.map(fn %{start: start, value: value} ->
        value
      end)
    end)
  end)
  # Flatten the list of lists of number
  |> Enum.map(&List.flatten(&1))
  # ignore any gear without exactly 2 numbers adjacent
  |> Enum.filter(&(length(&1) == 2))
  # Multiply the two numbers together
  |> Enum.map(&Enum.product(&1))
  # Sum the products
  |> Enum.sum()

# 84289137
IO.puts("Part 2: #{inspect(gear_ratios)}")
