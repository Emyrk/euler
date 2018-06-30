answer = File.stream!("numbers.txt")
|> Stream.map(fn s ->
    {v, _} =Integer.parse(s)
    v
end) 
|> Enum.reduce(0, fn v, acc ->
    acc + v
end)

# First 10 digits
answer = Integer.digits(answer) |> Enum.take(10) |> Integer.undigits
IO.puts answer

# Answer
# 5537376230390876637302048746832985971773659831892672
# 5537376230
