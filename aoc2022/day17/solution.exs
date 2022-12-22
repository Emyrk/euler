defmodule Cave do
  defstruct width: nil, grid: nil, top: 0, gas: [], gasIndex: 0

  def new(width, gas) do
    %Cave{width: width, gas: gas, grid: [row(width), row(width), row(width)]}
  end

  def run(cave) do
    rocks = [&Rock.minus/1, &Rock.cross/1, &Rock.lShape/1, &Rock.line/1, &Rock.square/1]

    0..2022
    |> Enum.reduce(cave, fn i, cave ->
      {cave, locations} = Enum.at(rocks, rem(i, 5)).(cave)
      # IO.puts("-- Pre -- at #{cave.top}")
      # IO.puts(Cave.print(cave, locations))
      # IO.puts("--")

      cave = Cave.run_blow(cave, locations)

      # IO.puts("-- Done -- at #{cave.top}")
      # IO.puts(Cave.print(cave))

      cave
    end)
  end

  def print(cave, locations \\ []) do
    cave.grid
    # |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.map(fn {row, y} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn {cell, x} ->
        cond do
          cell ->
            # IO.inspect({"#", x, y})
            "#"

          Enum.member?(locations, {x, y}) ->
            # IO.inspect({"@", x, y})
            "@"

          true ->
            "."
        end
      end)
      |> Enum.join()
    end)
    |> Enum.join("\n")
  end

  def run_fall(cave, locations) do
    # IO.inspect(Cave.save(cave, locations))
    {{cave, locations}, done} = Cave.fall(cave, locations)
    # IO.puts(" -- Falls --")
    # IO.puts(Cave.print(cave, locations))

    case done do
      :rest ->
        # {cave, locations} = Cave.blow(cave, locations)
        cave = Cave.save(cave, locations)

      :fell ->
        Cave.run_blow(cave, locations)
    end
  end

  def run_blow(cave, locations) do
    # IO.inspect(Cave.save(cave, locations))
    {cave, locations} = Cave.blow(cave, locations)
    # IO.puts("-- Blows --")
    # IO.puts(Cave.print(cave, locations))

    cave = Cave.run_fall(cave, locations)
  end

  def add_row(cave) do
    %Cave{cave | grid: cave.grid ++ [row(cave.width)]}
  end

  def save(cave, locations) do
    cave =
      Enum.reduce(locations, cave, fn {x, y}, cave ->
        row = Enum.at(cave.grid, y)
        row = List.replace_at(row, x, true)
        grid = List.replace_at(cave.grid, y, row)
        %{cave | grid: grid}
      end)

    highest =
      Enum.map(locations, fn {x, y} ->
        y
      end)
      |> Enum.max()

    %Cave{cave | top: Enum.max([cave.top, highest])}
  end

  def row(width) do
    1..width
    |> Enum.map(fn _ ->
      false
    end)
  end

  def fall(cave, locations) do
    # Can all go down?
    can =
      Enum.all?(locations, fn {x, y} ->
        y - 1 >= 0 and
          Enum.at(Enum.at(cave.grid, y - 1), x) == false
      end)

    if can do
      {{cave,
        Enum.map(locations, fn {x, y} ->
          {x, y - 1}
        end)}, :fell}
    else
      {{cave, locations}, :rest}
    end
  end

  def blow(cave, locations) do
    dir = Enum.at(cave.gas, rem(cave.gasIndex, length(cave.gas)))
    cave = %Cave{cave | gasIndex: cave.gasIndex + 1}

    case dir do
      ">" ->
        # Can all go right?
        can =
          Enum.all?(locations, fn {x, y} ->
            x + 1 < cave.width and
              Enum.at(Enum.at(cave.grid, y), x + 1) == false
          end)

        # IO.puts("right #{can}")

        if can do
          {cave,
           Enum.map(locations, fn {x, y} ->
             {x + 1, y}
           end)}
        else
          {cave, locations}
        end

      "<" ->
        # Can all go left?
        can =
          Enum.all?(locations, fn {x, y} ->
            x - 1 >= 0 and
              Enum.at(Enum.at(cave.grid, y), x - 1) == false
          end)

        # IO.puts("Left #{can}")

        if can do
          {cave,
           Enum.map(locations, fn {x, y} ->
             {x - 1, y}
           end)}
        else
          {cave, locations}
        end
    end
  end

  def has_row(cave, y) do
    row = Enum.at(cave.grid, y)

    if row != nil do
      cave
    else
      cave = add_row(cave)
    end
  end
end

defmodule Rock do
  def line(cave) do
    bottom = cave.top + 4
    # Ensure the space exists
    cave =
      bottom..(bottom + 4)
      |> Enum.reduce(cave, fn y, cave ->
        cave = Cave.has_row(cave, y)
      end)

    locations =
      bottom..(bottom + 4)
      |> Enum.map(fn y ->
        {2, y}
      end)

    {cave, locations}
  end

  def minus(cave) do
    bottom = cave.top + 3
    # Ensure the space exists
    cave =
      bottom..(bottom + 1)
      |> Enum.reduce(cave, fn y, cave ->
        cave = Cave.has_row(cave, y)
      end)

    locations =
      0..3
      |> Enum.map(fn x ->
        {x + 2, bottom}
      end)

    # IO.inspect("Put it at bottom #{bottom}")
    # IO.inspect(locations)
    {cave, locations}
  end

  def lShape(cave) do
    bottom = cave.top + 4
    # Ensure the space exists
    cave =
      bottom..(bottom + 3)
      |> Enum.reduce(cave, fn y, cave ->
        cave = Cave.has_row(cave, y)
      end)

    locations =
      [{0, 0}, {1, 0}, {2, 0}, {2, 1}, {2, 2}]
      |> Enum.map(fn {x, y} ->
        {x + 2, y + bottom}
      end)

    {cave, locations}
  end

  def cross(cave) do
    bottom = cave.top + 4
    # Ensure the space exists
    cave =
      bottom..(bottom + 3)
      |> Enum.reduce(cave, fn y, cave ->
        cave = Cave.has_row(cave, y)
      end)

    locations =
      [{1, 0}, {0, 1}, {1, 1}, {2, 1}, {1, 2}]
      |> Enum.map(fn {x, y} ->
        {x + 2, y + bottom}
      end)

    {cave, locations}
  end

  def square(cave) do
    bottom = cave.top + 4
    # Ensure the space exists
    cave =
      bottom..(bottom + 2)
      |> Enum.reduce(cave, fn y, acc ->
        acc = Cave.has_row(acc, y)
      end)

    locations =
      [{0, 0}, {0, 1}, {1, 0}, {1, 1}]
      |> Enum.map(fn {x, y} ->
        {x + 2, y + bottom}
      end)

    {cave, locations}
  end
end

defmodule Main do
  def main() do
    gas =
      File.read!("input.txt")
      |> String.trim("\n")
      |> String.split("")
      |> Enum.filter(fn x -> x == ">" or x == "<" end)

    cave = Cave.new(7, gas)

    cave = Cave.run(cave)
    IO.puts("Part 1: #{cave.top}")
    # IO.inspect(Cave.run(cave))
  end
end

Main.main()
