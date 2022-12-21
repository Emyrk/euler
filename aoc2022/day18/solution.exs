defmodule Cube do
  def bounds(cubes) do
    cubes
    |> Enum.reduce(nil, fn {{x, y, z}, _}, acc ->
      case acc do
        nil ->
          %{x: [x, x], y: [y, y], z: [z, z]}

        _ ->
          %{:x => [xmin, xmax], :y => [ymin, ymax], :z => [zmin, zmax]} = acc

          %{
            x: [min(x, xmin), max(x, xmax)],
            y: [min(y, ymin), max(y, ymax)],
            z: [min(z, zmin), max(z, zmax)]
          }
      end
    end)
    |> Enum.map(fn {key, [min, max]} ->
      {key, [min - 1, max + 1]}
    end)
    |> Map.new()
  end

  def reachable(cubes) do
    space = bounds(cubes)
    %{:x => [xmin, xmax], :y => [ymin, ymax], :z => [zmin, zmax]} = space
    # Start with the first space, and find all reachable cubes
    start = {xmin, ymin, zmin}
    reachable(cubes, start, %{}, space)
  end

  def reachable(cubes, current, reached, space) do
    %{:x => [xmin, xmax], :y => [ymin, ymax], :z => [zmin, zmax]} = space
    {x, y, z} = current

    cond do
      x < xmin or y < ymin or z < zmin ->
        reached

      x > xmax or y > ymax or z > zmax ->
        reached

      Map.has_key?(cubes, current) ->
        reached

      Map.has_key?(reached, current) ->
        reached

      true ->
        reached = Map.put(reached, current, true)

        reached =
          Enum.reduce(sides(current), reached, fn x, reached ->
            if Map.has_key?(cubes, x) do
              reached
            else
              reachable(cubes, x, reached, space)
            end
          end)
    end
  end

  def exposed_in(cubes, reached) do
    cubes
    |> Enum.reduce(0, fn {cube, _}, acc ->
      s = sides(cube)

      Enum.count(s, fn x ->
        not Map.has_key?(cubes, x) and Map.has_key?(reached, x)
      end) + acc
    end)
  end

  def exposed_count(cubes) do
    cubes
    |> Enum.reduce(0, fn {cube, _}, acc ->
      s = sides(cube)

      Enum.count(s, fn x ->
        not Map.has_key?(cubes, x)
      end) + acc
    end)
  end

  def sides({x, y, z}) do
    [
      {x + 1, y, z},
      {x - 1, y, z},
      {x, y + 1, z},
      {x, y - 1, z},
      {x, y, z + 1},
      {x, y, z - 1}
    ]
  end
end

defmodule Main do
  def cubes(file) do
    File.stream!(file)
    |> Enum.map(&String.trim(&1, "\n"))
    |> Enum.map(&String.split(&1, ","))
    |> Enum.map(fn x -> Enum.map(x, &String.to_integer/1) end)
    |> Enum.map(fn [x, y, z] -> {{x, y, z}, true} end)
    |> Map.new()
  end

  def partOne() do
    cubes = cubes("input.txt")

    Cube.exposed_count(cubes)
  end

  def partTwo() do
    cubes = cubes("input.txt")

    reached = Cube.reachable(cubes)
    Cube.exposed_in(cubes, reached)
  end
end

IO.inspect(Main.partOne())
IO.inspect(Main.partTwo())
