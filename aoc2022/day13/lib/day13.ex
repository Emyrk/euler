defmodule Signals do
  def solvePartTwo(file) do
    signals =
      File.stream!(file)
      # |> Enum.to_list()
      |> Enum.map(&String.trim(&1, "\n"))
      |> Enum.map(fn line ->
        case line do
          "" -> nil
          _ -> JSON.decode!(line)
        end
      end)
      |> Enum.filter(&(&1 != nil))

    div1 = [[2]]
    div2 = [[6]]

    signals =
      (signals ++ [div1, div2])
      |> Enum.sort(fn a, b ->
        compare(a, b) > 0
      end)
      |> Enum.with_index(1)
      |> Enum.filter(fn {a, _} ->
        a == div1 or a == div2
      end)
      |> Enum.map(fn {_, idx} ->
        idx
      end)
      |> Enum.product()
  end

  def solvePartOne(file) do
    File.stream!(file)
    # |> Enum.to_list()
    |> Enum.map(&String.trim(&1, "\n"))
    |> Enum.map(fn line ->
      case line do
        "" -> nil
        _ -> JSON.decode!(line)
      end
    end)
    |> Enum.chunk_every(3)
    |> Enum.map(&Enum.take(&1, 2))
    |> Enum.with_index(1)
    |> Enum.filter(fn {[a, b], idx} ->
      compare(a, b) > 0
    end)
    |> Enum.map(fn {[a, b], idx} ->
      idx
    end)
    |> Enum.sum()
  end

  # Integer compare
  def compare(a, b) when is_integer(a) and is_integer(b) do
    cond do
      a < b -> 1
      a == b -> 0
      a > b -> -1
    end
  end

  def compare(a, b) when is_list(a) and is_integer(b) do
    compare(a, [b])
  end

  def compare(a, b) when is_integer(a) and is_list(b) do
    compare([a], b)
  end

  def compare(a, b) when is_list(a) and is_list(b) do
    # Compare all elements
    cond do
      # Nothing left to compare
      length(a) == 0 and length(b) == 0 ->
        0

      length(a) == 0 ->
        1

      length(b) == 0 ->
        -1

      true ->
        [hd | tl] = a
        [hd2 | tl2] = b

        case Signals.compare(hd, hd2) do
          # If the elements don't terminate, continue with the next input
          0 -> Signals.compare(tl, tl2)
          # Terminate
          x -> x
        end
    end
  end

  def compare(a, b) when b == nil do
    0
  end
end

defmodule Mix.Tasks.Day13 do
  use Mix.Task

  @impl Mix.Task
  def run(_) do
    solved = Signals.solvePartOne("input.txt")
    IO.puts("Part 1: #{solved}")

    solved = Signals.solvePartTwo("input.txt")
    IO.puts("Part 2: #{solved}")
  end
end
