defmodule Grid do
  def idxHeight(v) do
    case v do
      ?S -> ?a
      ?E -> ?z
      _ -> v
    end
  end

  def parse(file) do
    grid =
      File.stream!(file)
      |> Enum.to_list()
      |> Enum.map(&String.trim(&1, "\n"))
      |> Enum.map(&String.to_charlist/1)

    width = Enum.at(grid, 0) |> Enum.count()
    height = Enum.count(grid)

    grid =
      grid
      |> List.flatten()
      |> Enum.with_index()

    grid
    |> Enum.reduce(Graph.new(), fn {curChar, curIdx}, acc ->
      acc = Graph.add_vertex(acc, curIdx)

      acc =
        case curChar do
          ?S -> Graph.label_vertex(acc, curIdx, :start)
          ?E -> Graph.label_vertex(acc, curIdx, :end)
          _ -> Graph.label_vertex(acc, curIdx, curChar)
        end

      around(grid, width, height, curIdx)
      |> Enum.reduce(acc, fn next, acc ->
        if next == nil do
          acc
        else
          {nextVal, nextIdx} = next
          {nextVal, curChar} = {Grid.idxHeight(nextVal), Grid.idxHeight(curChar)}

          diff = nextVal - curChar

          cond do
            # Bidirectional
            diff <= 1 and diff >= -1 ->
              Graph.add_edges(acc, [{curIdx, nextIdx}, {nextIdx, curIdx}])

            diff < -1 ->
              Graph.add_edges(acc, [{curIdx, nextIdx}])

            true ->
              # IO.puts(
              #   "Can't go from #{List.to_string([curChar])} to #{List.to_string([nextVal])} (#{diff})"
              # )

              acc
          end
        end
      end)
    end)
  end

  def around(grid, w, h, idx) do
    # Up
    up = Grid.get(grid, idx - w)
    # Down
    down = Grid.get(grid, idx + w)
    # Left
    left = Grid.get(grid, idx - 1)
    # Right
    right = Grid.get(grid, idx + 1)
    [up, down, left, right]
  end

  def get(grid, idx) do
    cond do
      idx < 0 -> nil
      true -> Enum.at(grid, idx)
    end
  end
end

defmodule Mix.Tasks.Day12 do
  use Mix.Task

  @impl Mix.Task
  def run(args) do
    g = Grid.parse("input.txt")
    # IO.inspect(graph)

    # Part 1
    %{start: s, end: e} =
      Graph.vertices(g)
      |> Enum.reduce(%{start: nil, end: nil}, fn v, acc ->
        # IO.inspect(Graph.vertex_labels(g, v))

        case Graph.vertex_labels(g, v) do
          [:start] -> %{acc | start: v}
          [:end] -> %{acc | end: v}
          _ -> acc
        end
      end)

    # IO.puts("Start at #{s}, ends at #{e}")
    result = Graph.a_star(g, s, e, fn _ -> 0 end)

    # IO.inspect(result)
    IO.puts("Part 1: #{length(result) - 1}")

    # Part 2
    %{starts: s, end: e} =
      Graph.vertices(g)
      |> Enum.reduce(%{starts: [], end: nil}, fn v, acc ->
        # IO.inspect(Graph.vertex_labels(g, v))

        labels = Graph.vertex_labels(g, v)

        cond do
          Enum.member?(labels, ?a) -> %{acc | starts: [v | acc.starts]}
          Enum.member?(labels, :start) -> %{acc | starts: [v | acc.starts]}
          Enum.member?(labels, :end) -> %{acc | end: v}
          true -> acc
        end
      end)

    lowest =
      s
      |> Enum.map(fn s ->
        Graph.a_star(g, s, e, fn _ -> 0 end)
      end)
      |> Enum.filter(&(&1 != nil))
      |> Enum.map(&(length(&1) - 1))
      |> Enum.min()

    IO.puts("Part 2: #{lowest}")
  end
end
