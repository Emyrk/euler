defmodule Room do
  defstruct name: "", flow: 0, tunnels: [], opened: false
end

defmodule RC do
  def comb(0, _), do: [[]]
  def comb(_, []), do: []

  def comb(m, [h | t]) do
    for(l <- comb(m - 1, t), do: [h | l]) ++ comb(m, t)
  end
end

defmodule Volcano do
  @roomRegex ~r/Valve ([A-Z][A-Z]) has flow rate=(\d+);\s+tunnels? leads? to valves? (.*)/

  def scoreLeft(rooms, time) do
    rooms
    |> Enum.filter(fn {_, room} ->
      room.flow > 0
    end)
    |> Enum.map(fn {name, room} ->
      room.flow
    end)
    |> Enum.sort(:desc)
    |> Enum.with_index()
    |> Enum.map(fn {flow, i} ->
      flow * (time - i)
    end)
    |> Enum.sum()
  end

  def make_rooms(rooms, names) do
    # IO.inspect(names)

    rooms
    |> Enum.map(fn {name, room} ->
      # IO.inspect({name, names})

      if Enum.member?(names, name) do
        {name, %{room | opened: true}}
      else
        {name, room}
      end
    end)
    |> Map.new()
  end

  def solve_2(start, graph, rooms, time) do
    splits = room_splits(rooms)
    IO.puts("Splits: #{length(splits)}")

    splits
    # |> Stream.map(fn n ->
    |> Enum.with_index()
    |> Task.async_stream(
      fn {{a, b}, n} ->
        ga = make_rooms(rooms, a)
        gb = make_rooms(rooms, b)

        # IO.inspect(gb)
        scoreA = Volcano.gtraverse("AA", graph, ga, 26)
        scoreB = Volcano.gtraverse("AA", graph, gb, 26)
        IO.puts("#{n}: #{scoreA} + #{scoreB} = #{scoreA + scoreB}")
        scoreA + scoreB
      end,
      max_concurrency: 12,
      timeout: :infinity
    )
    # |> Task.await_many(:infinity)
    |> Enum.to_list()
    |> Enum.map(fn {:ok, score} -> score end)
    |> Enum.max()
  end

  def room_splits(rooms) do
    names =
      rooms
      |> Enum.filter(fn {_, room} ->
        room.flow > 0
      end)
      |> Enum.map(fn {name, _} ->
        name
      end)

    a =
      1..length(names)
      |> Enum.reduce([], fn n, acc ->
        acc ++ RC.comb(n, names)
      end)
      |> Enum.filter(fn subset ->
        subset != nil
      end)

    a
    |> Enum.take(round((length(a) + 1) / 2))
    |> Enum.reduce([], fn aSet, acc ->
      bSet = names -- aSet
      [{aSet, bSet} | acc]
    end)

    # |> Enum.filter(fn {aSet, bSet} ->
    #   # This is not provable correct.
    #   length(aSet) > 2 and length(bSet) > 2
    # end)
  end

  def make_graph(rooms) do
    graph =
      rooms
      |> Enum.reduce(Graph.new(), fn {_, room}, graph ->
        # Add all vertices
        graph = Graph.add_vertex(graph, room.name, room)

        graph =
          room.tunnels
          |> Enum.reduce(graph, fn tunnel, graph ->
            Graph.add_edge(graph, room.name, tunnel)
          end)
      end)
  end

  def parse(file) do
    rooms =
      File.stream!(file)
      |> Enum.map(&String.trim(&1, "\n"))
      |> Enum.map(fn line ->
        Regex.run(@roomRegex, line)
      end)
      |> Enum.map(fn [_, name, flow, tunnels] ->
        rate = String.to_integer(flow)

        {name,
         %Room{
           name: name,
           flow: rate,
           tunnels: String.split(tunnels, ",") |> Enum.map(&String.trim/1),
           opened: rate == 0
         }}
      end)
      |> Map.new()

    {make_graph(rooms), rooms}
  end

  def gtraverse(roomName, graph, rooms, time) do
    gtraverse(roomName, graph, rooms, time, 0, 0)
  end

  def gtraverse(_roomName, _graph, _rooms, time, score, _bestScore) when time <= 0 do
    score
  end

  def gtraverse(roomName, graph, rooms, time, currentScore, bestScore) do
    all_opened = Enum.all?(rooms, fn {_, room} -> room.opened == true end)

    # IO.puts("Time is #{time} and all opened is #{all_opened}")

    cond do
      all_opened ->
        currentScore

      true ->
        room = Map.fetch!(rooms, roomName)

        # traverse to all rooms with a non-zero flow open valve.
        targets =
          rooms
          |> Enum.filter(fn {name, room} ->
            room.flow > 0 and not room.opened
          end)
          |> Enum.map(fn {name, _} -> name end)
          |> Enum.map(fn name ->
            {name, Graph.a_star(graph, roomName, name, fn _ -> 0 end)}
          end)
          |> Enum.filter(fn {_, path} ->
            path != nil and length(path) <= time
          end)
          |> Enum.map(fn {name, path} ->
            next = Map.fetch!(rooms, name)
            # Minus 2 because the first room is in the path, then 1 cost to open.
            # IO.puts(
            #   "Next is #{name} with #{time} - #{length(path)} - 2 = #{time - length(path) - 2} time left"
            # )

            timeLeft = time - (length(path) - 1) - 1
            score = next.flow * timeLeft

            {name, path, score, timeLeft}
          end)

        cond do
          length(targets) == 0 ->
            currentScore

          # All
          true ->
            # This is a cheeky way to prune branches
            # targets =
            #   Enum.sort_by(targets, fn {_, _, addition, timeLeft} -> addition end, :desc)
            #   |> Enum.take(10)

            scores =
              for target <- targets do
                {nextName, _path, addition, timeLeft} = target
                nextRoom = Map.fetch!(rooms, nextName)
                myScore = currentScore + addition
                bestScore = Enum.max([myScore, bestScore])
                nextRooms = Map.put(rooms, nextName, %{nextRoom | opened: true})

                if scoreLeft(nextRooms, timeLeft) < bestScore do
                  myScore
                else
                  gtraverse(
                    nextName,
                    graph,
                    Map.put(rooms, nextName, %{nextRoom | opened: true}),
                    timeLeft,
                    myScore,
                    bestScore
                  )
                end
              end

            Enum.max(scores)
        end
    end
  end
end

defmodule Mix.Tasks.Day16 do
  use Mix.Task

  @impl Mix.Task
  def run(_) do
    {graph, rooms} = Volcano.parse("input.txt")
    # IO.inspect(Volcano.scoreLeft(rooms, 30))
    # score = Volcano.gtraverse("AA", graph, rooms, 30)
    # IO.puts("Part 1: #{score}")

    # Part 2: 2193
    # elixir -S mix Day16  13040.94s user 236.13s system 601% cpu 36:48.56 total
    score = Volcano.solve_2("AA", graph, rooms, 26)
    IO.puts("Part 2: #{score}")
  end
end

# Took 300s without more optimizations
# Part 1: 1641
# elixir -S mix Day16  307.16s user 4.57s system 100% cpu 5:10.59 total
