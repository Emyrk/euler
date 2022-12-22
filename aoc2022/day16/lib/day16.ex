defmodule Room do
  defstruct name: "", flow: 0, tunnels: [], opened: false
end

defmodule Volcano do
  @roomRegex ~r/Valve ([A-Z][A-Z]) has flow rate=(\d+);\s+tunnels? leads? to valves? (.*)/

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

    {graph, rooms}
  end

  def gtraverse(roomName, graph, rooms, time) do
    gtraverse(roomName, graph, rooms, time, 0)
  end

  def gtraverse(_roomName, _graph, _rooms, time, score) when time <= 0 do
    score
  end

  def gtraverse(roomName, graph, rooms, time, currentScore) do
    all_opened = Enum.all?(rooms, fn {_, room} -> room.opened == true end)

    # IO.puts("Time is #{time} and all opened is #{all_opened}")

    cond do
      all_opened ->
        currentScore

      true ->
        room = Map.fetch!(rooms, roomName)
        self = []

        if not room.opened do
          self = {roomName, [], room.flow * (time - 1), time - 1}
        else
          self
        end

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
          |> Enum.concat(self)

        cond do
          length(targets) == 0 ->
            currentScore

          # All
          true ->
            # This is a cheeky way to prune branches
            targets =
              Enum.sort_by(targets, fn {_, _, addition, timeLeft} -> addition end, :desc)
              |> Enum.take(10)

            scores =
              for target <- targets do
                {nextName, _path, addition, timeLeft} = target
                nextRoom = Map.fetch!(rooms, nextName)

                gtraverse(
                  nextName,
                  graph,
                  Map.put(rooms, nextName, %{nextRoom | opened: true}),
                  timeLeft,
                  currentScore + addition
                )
              end

            Enum.max(scores)
        end
    end
  end

  def gtraverse2(roomA, roomB, graph, rooms, time) do
    gtraverse2(roomA, roomB, graph, rooms, time, time, 0)
  end

  def gtraverse2(_roomA, _roomB, _graph, _rooms, aTime, bTime, score)
      when aTime <= 0 and bTime <= 0 do
    score
  end

  def gtraverse2(roomA, roomB, graph, rooms, aTime, bTime, currentScore) do
    all_opened = Enum.all?(rooms, fn {_, room} -> room.opened == true end)

    # IO.puts("Time is #{time} and all opened is #{all_opened}")

    cond do
      all_opened ->
        currentScore

      true ->
        # a = Map.fetch!(rooms, roomA)
        # b = Map.fetch!(rooms, roomB)

        # traverse to all rooms with a non-zero flow open valve.
        targets =
          rooms
          |> Enum.filter(fn {name, room} ->
            room.flow > 0 and not room.opened
          end)
          |> Enum.map(fn {name, _} -> name end)
          |> Enum.map(fn name ->
            {
              name,
              Graph.a_star(graph, roomA, name, fn _ -> 0 end),
              Graph.a_star(graph, roomB, name, fn _ -> 0 end)
            }
          end)
          |> Enum.filter(fn {_, apath, bpath} ->
            apath != nil and bpath != nil and (length(apath) <= aTime and length(bpath) < bTime)
          end)
          |> Enum.map(fn {name, aPath, bPath} ->
            next = Map.fetch!(rooms, name)
            # Minus 2 because the first room is in the path, then 1 cost to open.
            # IO.puts(
            #   "Next is #{name} with #{time} - #{length(path)} - 2 = #{time - length(path) - 2} time left"
            # )

            aTimeLeft = aTime - (length(aPath) - 1) - 1
            bTimeLeft = bTime - (length(bPath) - 1) - 1

            aScore = next.flow * aTimeLeft
            bScore = next.flow * bTimeLeft

            bTup =
              if bTimeLeft < 0 do
                {[], 0, bTime}
              else
                {bPath, bScore, bTimeLeft}
              end

            {_, bScore, _} = bTup

            aTup =
              if aTimeLeft < 0 do
                {[], 0, aTime}
              else
                {aPath, aScore, aTimeLeft}
              end

            {_, aScore, _} = aTup

            {name, aTup, bTup, Enum.max([aScore, bScore])}
          end)

        cond do
          length(targets) == 0 ->
            currentScore

          # All
          true ->
            # This is a cheeky way to prune branches
            targets =
              Enum.sort_by(targets, fn {_name, _a, _b, bestScore} -> bestScore end, :desc)
              |> Enum.take(15)

            scores =
              for {name, {_aPath, aScore, aTimeLeft}, {_bPath, bScore, bTimeLeft}, best} <-
                    targets,
                  {name2, {_aPath2, aScore2, aTimeLeft2}, {_bPath2, bScore2, bTimeLeft2}, best2} <-
                    targets do
                cond do
                  name == name2 ->
                    currentScore

                  true ->
                    one = Map.fetch!(rooms, name)
                    two = Map.fetch!(rooms, name2)

                    # I am stuck since the timeLeft will not be the same for both
                    gtraverse2(
                      name,
                      name2,
                      graph,
                      Map.put(
                        Map.put(rooms, one, %{one | opened: true}),
                        two,
                        %{two | opened: true}
                      ),
                      aTimeLeft,
                      bTimeLeft2,
                      currentScore + aScore + bScore2
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
    {graph, rooms} = Volcano.parse("easy.txt")
    # score = Volcano.gtraverse("AA", graph, rooms, 30)
    # IO.puts("Part 1: #{score}")

    score = Volcano.gtraverse2("AA", "AA", graph, rooms, 26)
    IO.puts("Part 2: #{score}")
  end
end

# Took 300s without more optimizations
# Part 1: 1641
# elixir -S mix Day16  307.16s user 4.57s system 100% cpu 5:10.59 total
