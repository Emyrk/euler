defmodule Signals do
  def draw(connected, signals) do
    IO.puts("----")

    signals =
      Enum.map(signals, fn {sig, idx} ->
        sig
      end)

    connected
    |> Enum.with_index()
    |> Enum.each(fn {sigIdx, connIdx} ->
      a = Enum.at(signals, sigIdx)
      b = Enum.at(signals, Enum.at(connected, connIdx + 1, sigIdx))
      sig = inspect(a, charlists: :as_lists)
      IO.puts("#{sig}, V=#{Signals.compare(a, b)}")
    end)

    IO.puts("----")
  end

  def solvePartTwoFail(file) do
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
      |> Enum.with_index()

    # Time to order them
    g =
      signals
      |> Enum.reduce(Graph.new(), fn {curSignal, curNode}, acc ->
        acc = Graph.add_vertex(acc, curNode)

        if curSignal == div1 or curSignal == div2 do
          acc = Graph.label_vertex(acc, curNode, :div)
        else
          acc
        end

        signals
        |> Enum.reduce(acc, fn {signal, idx}, acc ->
          cond do
            curNode == idx ->
              acc

            true ->
              case compare(curSignal, signal) do
                1 ->
                  a = inspect(curSignal, charlists: :as_lists)
                  b = inspect(signal, charlists: :as_lists)
                  # IO.puts("#{a} <1> #{b}")
                  Graph.add_edges(acc, [{curNode, idx}])

                _ ->
                  acc
              end
          end
        end)
      end)

    [connected | _] = Graph.components(g)
    Signals.draw(connected, signals)
    # {_, t} = Graph.to_dot(g)
    # IO.puts(t)
    IO.inspect(connected)

    labeled =
      [length(signals) - 1, length(signals) - 2]
      |> Enum.map(fn idx ->
        Enum.find_index(connected, fn x ->
          x == idx
        end)
      end)
      |> Enum.map(&(&1 + 1))
      |> Enum.product()
  end

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
