# Faster indexing into arrays
# https://hexdocs.pm/arrays/Arrays.html#module-using-arrays
Mix.install([:arrays])

defmodule Parse do
  def line(line) do
    [_, numbers] = String.split(line, ":")
    [winning, have] = String.split(numbers, "|")

    [numbers(winning), numbers(have)]
  end

  def numbers(numbers) do
    String.trim(numbers)
    |> String.split(" ")
    |> Enum.filter(&(&1 != ""))
    |> Enum.map(&String.to_integer/1)
    |> MapSet.new()
  end

  # When the card is 0, we don't mess with any counts.
  def run_card(index, card, acc) when card == 0 do
    acc
  end

  def run_card(index, card, acc) when card > 0 do
    # We have a winning card, so we bump the count of the next
    # N cards by the number of this card we have.
    bump_by = Arrays.get(acc, index)

    # IO.puts("#{index}, #{card}, #{index + 1} #{index + card}")

    (index + 1)..(index + card)
    |> Enum.reduce(acc, fn i, acc ->
      # IO.puts("#{i}: #{inspect(Arrays.get(acc, i))} + #{bump_by} from #{index}")
      Arrays.replace(acc, i, Arrays.get(acc, i) + bump_by)
    end)
  end
end

cards =
  File.stream!("input.txt")
  |> Enum.map(&String.trim(&1, "\n"))
  |> Enum.map(&Parse.line/1)

# Part one
points =
  cards
  |> Enum.map(fn [winning, have] ->
    size =
      MapSet.intersection(winning, have)
      |> MapSet.size()

    if size == 0 do
      0
    else
      :math.pow(2, size - 1)
    end
  end)
  |> Enum.sum()

IO.puts("Part one: #{trunc(points)}")

# Part two
# Card_wins is the list of cards and the number of matches they have
card_wins =
  cards
  |> Enum.map(fn [winning, have] ->
    size =
      MapSet.intersection(winning, have)
      |> MapSet.size()
  end)

total_cards =
  card_wins
  |> Enum.with_index()
  |> Enum.reduce(
    # An array of the # of each card in existence. At the start, 1 card of each
    # exists.
    Arrays.empty(size: length(card_wins), default: 1),
    fn {card, i}, acc ->
      Parse.run_card(i, card, acc)
      # cond do
      #   card == 0 ->
      #     # No matches, so we don't mess with any card counts.
      #     acc
      # end

      # IO.puts("#{i}: #{inspect(card)}")
    end
  )
  |> Enum.sum()

IO.puts("Part two: #{inspect(total_cards)}")
