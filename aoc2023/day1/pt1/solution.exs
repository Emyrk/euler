reduced =
  File.stream!("input.txt")
  |> Enum.to_list()
  |> Enum.map(&String.trim(&1, "\n"))
  |> Enum.map(fn line ->
    line
    |> String.to_charlist()
    |> Enum.reduce([], fn i, acc ->
      if i in ?0..?9 do
        if(length(acc) > 0) do
          [hd | _] = acc
          [hd, i]
        else
          [i, i]
        end
      else
        acc
      end
    end)
  end)
  |> Enum.map(fn tuples ->
    tuples
    |> List.to_string()
    |> String.to_integer()
  end)
  |> Enum.sum()

IO.puts("Answer: #{reduced |> inspect()}")
