defmodule Stack do
  defstruct elements: []

  def push(stack, elements) do
    %Stack{stack | elements: elements ++ stack.elements}
  end

  # def pop(%Stack{elements: []}, _), do: raise("Stack is empty!")

  # def pop(%Stack{elements: [top | rest]}) do
  #   {top, %Stack{elements: rest}}
  # end

  def pop(%Stack{elements: list}, n) do
    {top, rest} = Enum.split(list, n)
    {top, %Stack{elements: rest}}
  end

  def depth(%Stack{elements: elements}), do: length(elements)
end

defmodule Main do
  def main do
    {stacks, moves} =
      File.stream!("input.txt")
      |> Enum.to_list()
      |> Enum.map(&String.trim(&1, "\n"))
      |> Enum.split_while(&(&1 != ""))

    # Parsed stacks are the stack numbers and their letters.
    parsedStacks =
      stacks
      |> Enum.map(fn line ->
        String.graphemes(line)
        |> Enum.chunk_every(4)
        |> Enum.map(&Enum.at(&1, 1))
      end)
      |> Enum.reverse()
      # First row is just the index of the stack. Drop it
      |> Enum.drop(1)
      # Init our map of stacks
      # %{1 => %Stack{}, 2 => %Stack{}, 3 => %Stack{}, ...}
      |> Enum.reduce(%{}, fn line, all ->
        line
        |> Enum.with_index()
        |> Enum.reduce(all, fn {x, i}, acc ->
          i = i + 1

          acc =
            cond do
              !Map.has_key?(acc, i) ->
                Map.put(acc, i, %Stack{elements: []})

              true ->
                acc
            end

          acc =
            if x == " " do
              acc
            else
              Map.put(acc, i, Stack.push(Map.fetch!(acc, i), [x]))
            end

          acc
        end)
      end)

    resultStacks =
      moves
      # Ignore first line of moves
      |> Enum.drop(1)
      # For each move, run it
      |> Enum.reduce(parsedStacks, fn line, stacks ->
        [_, num, _, from, _, to] = String.split(line, " ")
        num = String.to_integer(num)
        from = String.to_integer(from)
        to = String.to_integer(to)

        {val, fromS} = Stack.pop(Map.fetch!(stacks, from), num)
        toS = Stack.push(Map.fetch!(stacks, to), val)

        stacks =
          stacks
          |> Map.put(from, fromS)
          |> Map.put(to, toS)

        stacks
      end)
      # Only grab the top element of each stack
      |> Enum.reduce(%{}, fn {k, v}, acc ->
        {[val | _], _} = Stack.pop(v, 1)

        acc
        |> Map.put(k, val)
      end)
      # Sort by stack number
      |> Enum.sort_by(fn {k, _} -> k end)
      # Grab the letters
      |> Enum.map(fn {_, v} -> v end)
      # Join them together
      |> Enum.join("")

    IO.puts("Part 2: #{resultStacks}")
  end
end

Main.main()
