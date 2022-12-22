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

  def gtraverse(_roomName, _graph, _rooms, time, score) when time <= 0 do
    score
  end

  def gopen(_roomName, _graph, _rooms, time, score) when time <= 0 do
    score
  end

  def gtraverse(roomName, graph, rooms, time) do
    gtraverse(roomName, graph, rooms, time, 0)
  end

  def gopen(roomName, graph, rooms, time, score) do
    room = Map.fetch!(rooms, roomName)
    time = time - 1
    rooms = Map.put(rooms, roomName, %{room | opened: true})
    add = room.flow * time
    IO.puts("Opening #{roomName} with #{time} time left and score #{add}")
    gtraverse(roomName, graph, rooms, time, score + add)
  end

  def gtraverse(roomName, graph, rooms, time, score) do
    all_opened = Enum.all?(rooms, fn {_, room} -> room.opened == true end)

    cond do
      all_opened ->
        score

      true ->
        room = Map.fetch!(rooms, roomName)
        self = []

        if not room.opened do
          self = {roomName, [], room.flow * (time - 1)}
        else
          self
        end

        # traverse to all rooms with a non-zero flow open valve.
        target =
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
            score = next.flow * (time - length(path) - 2)

            {name, path, score}
          end)
          |> Enum.concat(self)
          |> Enum.max_by(fn {_, _, score} -> score end)

        IO.inspect(target)
        0

        # scores =
        #   cond do
        #     length(targets) > 0 ->
        #       for {target, path} <- targets do
        #         gtraverse(target, graph, rooms, time - length(path) - 1, score)
        #       end

        #     true ->
        #       [score]
        #   end

        # IO.inspect([roomName, scores, room.opened])

        # if room.opened do
        #   Enum.max(scores)
        # else
        #   Enum.max([gopen(roomName, graph, rooms, time, score) | scores])
        # end
    end
  end

  # def traverse(_roomName, _rooms, time, score) when time == 0 do
  #   score
  # end

  # def open(_roomName, _rooms, time, score) when time == 0 do
  #   score
  # end

  # def traverse(roomName, rooms, time) do
  #   traverse(roomName, rooms, time, 0)
  # end

  # def traverse(roomName, rooms, time, score) do
  #   all_opened = Enum.all?(rooms, fn {_, room} -> room.opened == true end)

  #   cond do
  #     all_opened ->
  #       IO.puts("All rooms opened with #{time} time left")
  #       score

  #     true ->
  #       # IO.puts("Traversing #{roomName} with #{time} time left")
  #       room = Map.fetch!(rooms, roomName)
  #       # Possible scores is traversing all tunnels and opening the valve.
  #       scores =
  #         for tunnel <- room.tunnels do
  #           traverse(tunnel, rooms, time - 1)
  #         end

  #       if room.opened do
  #         Enum.max(scores)
  #       else
  #         Enum.max([open(roomName, rooms, time, score) | scores])
  #       end
  #   end
  # end

  # def open(roomName, rooms, time, score) do
  #   room = Map.fetch!(rooms, roomName)
  #   time = time - 1
  #   rooms = Map.put(rooms, roomName, %{room | opened: true})
  #   add = room.flow * time
  #   # IO.puts("Opening #{roomName} with #{time} time left and score #{add}")
  #   traverse(roomName, rooms, time, score + add)
  # end
end

defmodule Mix.Tasks.Day16 do
  use Mix.Task

  @impl Mix.Task
  def run(_) do
    {graph, rooms} = Volcano.parse("small.txt")
    # score = Volcano.traverse("AA", rooms, 30)
    score = Volcano.gtraverse("AA", graph, rooms, 30)
    IO.inspect(score)
    # IO.puts("Part 1: #{score}")

    #    solved = Signals.solvePartOne("input.txt")
    #    IO.puts("Part 1: #{solved}")
    #
    #    solved = Signals.solvePartTwo("input.txt")
    #    IO.puts("Part 2: #{solved}")
  end
end
