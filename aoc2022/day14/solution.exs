defmodule Cave do
  defstruct rocks: %{}, sand: %{}, bottom: {nil, nil}, floor: nil

  def blocked?(cave, spot) do
    {_, y} = spot

    cond do
      cave.floor != nil and y == cave.floor ->
        true

      Map.get(cave.rocks, spot) == true ->
        true

      Map.get(cave.sand, spot) == true ->
        true

      true ->
        false
    end
  end

  # Parse returns a cave with rocks
  def parse(file) do
    cave =
      File.stream!(file)
      |> Enum.map(&String.trim(&1, "\n"))
      |> Enum.reduce(%Cave{rocks: %{}}, fn line, acc ->
        %Cave{rocks: Map.merge(acc.rocks, Cave.parse_line(line))}
      end)

    %Cave{cave | bottom: Map.keys(cave.rocks) |> Enum.max_by(fn {_, y} -> y end)}
  end

  def pour(cave, init) do
    Cave.pour(cave, init, init)
  end

  def pour(cave, init, sand) do
    {x, y} = sand
    {_, bottom_y} = cave.bottom
    # IO.puts("Pouring #{x}, #{y}")

    cond do
      # Check if we fall forever
      cave.floor == nil and y > bottom_y ->
        cave

      # Check right below
      Cave.blocked?(cave, {x, y + 1}) == false ->
        Cave.pour(cave, init, {x, y + 1})

      # Diag bottom left
      Cave.blocked?(cave, {x - 1, y + 1}) == false ->
        Cave.pour(cave, init, {x - 1, y + 1})

      # Diag bottom right
      Cave.blocked?(cave, {x + 1, y + 1}) == false ->
        Cave.pour(cave, init, {x + 1, y + 1})

      # Come to rest
      Cave.blocked?(cave, {x, y}) == false ->
        # IO.puts("Resting #{x}, #{y}")
        cave = %Cave{cave | rocks: cave.rocks, sand: Map.put(cave.sand, {x, y}, true)}
        Cave.pour(cave, init)

      # Come to rest,but spot is taken
      true ->
        cave
    end
  end

  def parse_line(line) do
    line
    |> String.split("->")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.split(&1, ","))
    |> Enum.map(fn v ->
      Enum.map(v, &String.to_integer/1)
    end)
    |> Enum.reduce(%{last: {nil, nil}, rocks: %{}}, fn [x, y], acc ->
      cond do
        acc[:last] == {nil, nil} ->
          %{acc | last: {x, y}}

        true ->
          {a, b} = acc[:last]

          %{
            last: {x, y},
            rocks:
              for i <- a..x, j <- b..y do
                {i, j}
              end
              |> Map.new(fn {x, y} -> {{x, y}, true} end)
              |> Map.merge(acc[:rocks])
          }
      end
    end)
    |> Map.get(:rocks)
  end
end

defmodule Main do
  def main_one do
    cave = Cave.parse("input.txt")

    cave = Cave.pour(cave, {500, 0})
    IO.puts("Part 1: #{Enum.count(cave.sand)}")
  end

  def main_two do
    cave = Cave.parse("input.txt")
    {_, y} = cave.bottom
    cave = %Cave{cave | floor: y + 2}

    cave = Cave.pour(cave, {500, 0})
    IO.puts("Part 2: #{Enum.count(cave.sand)}")
  end
end

Main.main_one()
Main.main_two()
