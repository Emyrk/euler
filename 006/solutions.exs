n = 100
sum_of_squares = 1..n |> Enum.reduce(0, fn i, acc ->
    trunc(:math.pow(i, 2)) + acc
end)

square_of_sums = 1..n |> Enum.reduce(0, fn i, acc ->
    acc + i
end)
square_of_sums = trunc(:math.pow(square_of_sums, 2))
IO.puts square_of_sums - sum_of_squares