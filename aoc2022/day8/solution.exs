defmodule Grid do
  # Calculates
  def visible(row) do
    row
    |> Enum.reduce(%{count: 0, current: 0}, fn x, acc ->
      if x > acc.current do
        %{count: acc.count + 1, current: x}
      else
        %{count: acc.count, current: acc.current}
      end
    end)

    for n <- [1, 2, 3, 4], do: n * n
  end
end

grid =
  File.stream!("easy.txt")
  |> Enum.to_list()
  |> Enum.map(&String.trim(&1, "\n"))
  |> Enum.map(&String.graphemes/1)

IO.inspect(grid)

left
|> Enum.reduce(%{count: 0, current: 0}, fn row, acc ->
  Enum.reduce()

  if x == "#" do
    acc + 1
  else
    acc
  end
end)
