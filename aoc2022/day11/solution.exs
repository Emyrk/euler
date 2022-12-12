defmodule Monkey do
  defstruct items: [], operation: nil, test: nil, ifTrue: nil, ifFalse: nil, inspected: 0

  @regexString Regex.compile!(
                 "Monkey.*\n" <>
                   "\s+Starting items:\s(.*)\n" <>
                   "\s+Operation:\s(.*)\n" <>
                   "\s+Test:\s(.*)\n" <>
                   "\s+If true:\s(.*)\n" <>
                   "\s+If false:\s(.*)"
               )

  # ~r/Monkey.*\n\s*Starting items\:\s/

  def parseMonkeys(text) do
    Regex.scan(@regexString, text)
    |> Enum.map(fn [_, items, op, test, ifTrue, ifFalse] ->
      %Monkey{
        items: Monkey.parseItems(items),
        operation: Monkey.parseOperation(op),
        test: Monkey.parseTest(test),
        ifTrue: Monkey.parseThrow(ifTrue),
        ifFalse: Monkey.parseThrow(ifFalse)
      }
    end)
  end

  def parseItems(text) do
    text
    |> String.split(",")
    |> Enum.map(&String.trim(&1))
    |> Enum.map(&String.to_integer/1)
  end

  # new = old * old
  def parseOperation(text) do
    matches = Regex.run(~r/new = old ([+*]) (.*)/, text)

    mathOp =
      case Enum.at(matches, 1) do
        "+" -> &(&1 + &2)
        "*" -> &(&1 * &2)
      end

    scaler = Enum.at(matches, 2)

    cond do
      scaler == "old" -> &mathOp.(&1, &1)
      true -> &mathOp.(&1, String.to_integer(scaler))
    end
  end

  # divisible by 17
  def parseTest(text) do
    matches = Regex.run(~r/divisible by (\d+)/, text)
    scaler = String.to_integer(Enum.at(matches, 1))

    scaler
  end

  def parseThrow(text) do
    matches = Regex.run(~r/throw to monkey (\d+)/, text)
    String.to_integer(Enum.at(matches, 1))
  end
end

defmodule Main do
  def runRound(monkeys, worry) do
    monkeys
    |> Enum.with_index()
    |> Enum.reduce(monkeys, fn {_, idx}, acc ->
      Main.run(acc, idx, worry)
    end)
  end

  def run(monkeys, idx, worry) do
    curr = Enum.at(monkeys, idx)
    items = curr.items

    monkeys =
      List.update_at(monkeys, idx, fn monkey ->
        %{monkey | inspected: monkey.inspected + length(items), items: []}
      end)

    items
    # Run operation on each item
    |> Enum.map(fn item ->
      curr.operation.(item)
    end)
    # Divide by 3 for worry
    |> Enum.map(worry)
    |> Enum.reduce(monkeys, fn item, acc ->
      # Test true/false

      next =
        case rem(item, curr.test) == 0 do
          true -> curr.ifTrue
          false -> curr.ifFalse
        end

      List.update_at(acc, next, fn monkey ->
        %{monkey | items: monkey.items ++ [item]}
      end)
    end)
  end

  def solve(monkeys, rounds, worry) do
    monkeys =
      1..rounds
      |> Enum.reduce(monkeys, fn _, acc ->
        # IO.puts("Round: #{idx}")
        acc = Main.runRound(acc, worry)
      end)

    buisness =
      Enum.sort(monkeys, fn a, b ->
        a.inspected > b.inspected
      end)
      |> Enum.take(2)
      |> Enum.chunk_every(2)
      |> Enum.map(fn [a, b] ->
        a.inspected * b.inspected
      end)
      |> Enum.at(0)

    # IO.inspect(monkeys, charlists: :as_lists)
    buisness
  end

  def partOne do
    {:ok, text} = File.read("input.txt")
    monkeys = Monkey.parseMonkeys(text)

    Main.solve(monkeys, 20, &floor(&1 / 3))
  end

  def partTwo do
    {:ok, text} = File.read("input.txt")
    monkeys = Monkey.parseMonkeys(text)

    max =
      monkeys
      |> Enum.reduce(1, fn monkey, acc ->
        acc = acc * monkey.test
      end)

    Main.solve(monkeys, 10000, &rem(&1, max))
  end
end

IO.puts("Part 1: #{Main.partOne()}")
IO.puts("Part 2: #{Main.partTwo()}")
