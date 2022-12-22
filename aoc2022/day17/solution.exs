defmodule Cave do
  defstruct width: nil, grid: nil, top: 0, gas: [], gasIndex: 0

  def new(width, gas) do
    %Cave{width: width, gas: gas, grid: [row(width), row(width), row(width)]}
  end

  def add_row(cave) do
    %Cave{cave | grid: cave.grid ++ [row(cave.width)]}
  end

  def row(width) do
    1..width
    |> Enum.map(fn _ ->
      false
    end)
  end

  # def run_rock(cave, rock_do) do
  #   cave = rock_do(cave, rock)
  # end

  # def spawn_rock(cave, rock) do
  # end

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
    bottom = cave.top + 3
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
  end

  def simulate(cave, locations) do
    # First you push
  end
end

defmodule Main do
  def main() do
    gas =
      File.read!("input.txt")
      |> String.trim("\n")
      |> String.split("")

    cave = Cave.new(7, gas)
    IO.inspect(cave, [])

    IO.inspect(Rock.line(cave))
  end
end

Main.main()
