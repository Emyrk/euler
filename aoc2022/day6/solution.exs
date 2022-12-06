defmodule Problem do
  def solve(n) do
    File.stream!("input.txt")
    # |> Enum.to_list()
    |> Stream.map(&String.trim(&1, "\n"))
    |> Enum.at(0)
    |> Stream.unfold(&String.next_codepoint/1)
    |> Enum.to_list()
    |> Enum.with_index()
    |> Enum.reduce_while([], fn {x, idx}, acc ->
      cond do
        idx < n ->
          # First 4
          {:cont, [x | acc]}

        true ->
          acc = [x | List.delete_at(acc, length(acc) - 1)]

          if length(Enum.uniq(acc)) == n do
            {:halt, idx + 1}
          else
            {:cont, acc}
          end
      end
    end)
  end
end

IO.puts("Part 1: #{Problem.solve(4)}")
IO.puts("Part 2: #{Problem.solve(14)}")
