defmodule Materials do
  defstruct ore: 0, clay: 0, obsidian: 0, geode: 0

  def empty() do
    Materials.to_array(%Materials{})
  end

  def to_array(mats) do
    [mats.ore, mats.clay, mats.obsidian, mats.geode]
  end

  def more(a, b) do
    Enum.zip(a, b)
    |> Enum.all?(fn {a, b} ->
      a >= b
    end)
  end

  def add(a, b) do
    Enum.zip(a, b)
    |> Enum.map(fn {a, b} -> a + b end)
  end

  def sub(a, b) do
    Enum.zip(a, b)
    |> Enum.map(fn {a, b} -> a - b end)
  end
end

defmodule Blueprint do
  @idxMap %{
    0 => :ore,
    1 => :clay,
    2 => :obsidian,
    3 => :geode
  }

  # Return a list of [%{bots: [can_build], mats: [remain]}]
  # All possible ways to build the blueprint with the materials
  def can_all(print, have, allow) do
    # First state is if you build no bots
    state = %{bots: Materials.empty(), mats: have}
    [state | can_all(state, print, have, allow)]
  end

  def can_all(state, print, have, allow) do
    costs = Enum.with_index(print)

    builds =
      for {cost, idx} <- costs do
        case Enum.at(allow, idx) do
          true ->
            next = List.update_at(state.bots, idx, &(&1 + 1))

            if Materials.more(have, cost) do
              this = %{
                bots: next,
                mats: Materials.sub(have, cost)
              }

              # Only 1 robot per minute...
              [this]
              # [this] ++ can_all(this, print, this.mats)
            end

          _ ->
            nil
        end
      end
      |> List.flatten()
      |> Enum.filter(&(&1 != nil))
      |> Enum.uniq()
  end

  @regexString Regex.compile!(
                 # <>
                 "Blueprint .*:\s+" <>
                   "Each ore robot costs ([^.]*).\s+" <>
                   "Each clay robot costs ([^.]*).\s+" <>
                   "Each obsidian robot costs ([^.]*).\s+" <>
                   "Each geode robot costs ([^.]*)."
               )

  def parse(text) do
    [_ | bots] = Enum.at(Regex.scan(@regexString, text), 0)

    # IO.inspect(match)
    # IO.inspect(bots)

    bots
    |> Enum.map(&String.trim(&1))
    |> Enum.map(&Blueprint.parse_resources/1)

    # |> Enum.with_index()
    # |> Enum.reduce(%Blueprint{}, fn {cost, idx}, acc ->
    #   case idx do
    #     0 -> %{acc | ore_bot: cost}
    #     1 -> %{acc | clay_bot: cost}
    #     2 -> %{acc | obsidian_bot: cost}
    #     3 -> %{acc | geode_bot: cost}
    #   end
    # end)
  end

  def parse_resources(text) do
    text
    |> String.split("and")
    |> Enum.map(&String.trim(&1))
    |> Enum.map(&String.split(&1, " "))
    |> Enum.reduce(%Materials{}, fn [count, resource], acc ->
      case resource do
        "ore" -> %{acc | ore: String.to_integer(count)}
        "clay" -> %{acc | clay: String.to_integer(count)}
        "obsidian" -> %{acc | obsidian: String.to_integer(count)}
        "geode" -> %{acc | geode: String.to_integer(count)}
      end
    end)
    |> Materials.to_array()
  end
end

defmodule Simulate do
  def simulate(blueprints, minutes) do
    state = %{
      bots: Materials.to_array(%Materials{ore: 1}),
      mats: Materials.to_array(%Materials{ore: 0})
    }

    for print <- blueprints do
      0..minutes
      |> Enum.reduce([state], fn min, acc ->
        nodes =
          for state <- acc do
            branches(state, print)
          end
          |> List.flatten()
          |> Enum.uniq()

        IO.puts("Minute #{min}: #{length(nodes)} nodes")
        # IO.inspect(prune(nodes))
        prune(nodes)
      end)
    end
  end

  def prune(states) do
    states
    |> prune_by_geodes()

    # |> prune_by_mats()

    # |> prune_by_bots()
  end

  def prune_by_mats(states) do
    states
    |> Enum.group_by(fn state ->
      state.bots
    end)
    # TODO: I think this max function is wrong
    |> Enum.map(fn {_, states} ->
      Enum.max_by(states, fn state ->
        state.mats
      end)
    end)
  end

  def prune_by_bots(states) do
    states
    |> Enum.group_by(fn state ->
      state.mats
    end)
    # TODO: I think this max function is wrong
    |> Enum.map(fn {_, states} ->
      Enum.max_by(states, fn state ->
        state.bots
      end)
    end)
  end

  def prune_by_geodes(states) do
    states
    |> Enum.group_by(fn state ->
      state.mats
    end)
    # TODO: I think this max function is wrong
    |> Enum.map(fn {_, states} ->
      Enum.max_by(states, fn state ->
        Enum.at(state.mats, 3)
      end)
    end)
  end

  def branches(state, print) do
    # states is %{bots: [], mats: []}
    allow =
      print
      |> Enum.map(fn cost ->
        not Materials.more(state.bots, cost)
      end)

    builds = Blueprint.can_all(print, state.mats, allow)

    for build <- builds do
      # For each state, we run the build and collect. Returning the list of new states
      collect = state.bots

      %{
        bots: Materials.add(state.bots, build.bots),
        mats: Materials.add(collect, build.mats)
      }
    end
  end
end

defmodule Main do
  def main do
    prints =
      File.stream!("easy.txt")
      |> Enum.map(&String.trim(&1, "\n"))
      |> Enum.map(&Blueprint.parse/1)

    # |> Enum.at(0)

    # IO.inspect(prints)

    result =
      Simulate.simulate(prints, 23)
      |> Enum.map(fn list ->
        Enum.max_by(list, fn state ->
          Enum.at(state.mats, 3)
        end)
      end)

    IO.inspect(result, charlists: :as_lists)

    score =
      result
      |> Enum.with_index(1)
      |> Enum.map(fn {state, idx} ->
        geodes = Enum.at(state.mats, 3)
        geodes * idx
      end)

    IO.puts("Score: #{Enum.sum(score)}")
  end
end

Main.main()
