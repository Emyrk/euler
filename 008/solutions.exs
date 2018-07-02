defmodule Read do
    def get_digits() do
        File.stream!("numbers.txt")
        |> Stream.map(fn line ->
            {i, _} = Integer.parse(line)
            Integer.digits(i)
        end)
        |> Enum.to_list
        |> List.flatten
    end
end

defmodule Bruteforce do
    def largest_product() do
        numbers = Read.get_digits()
        start = Enum.take(numbers, 13)
        numbers = Enum.drop(numbers, 13)
        state = numbers
        |> Enum.reduce({start, product(start)}, fn n, state ->
            {list, largest} = state
            [chopped | t] = list
            list = t ++ [n]
            if n <= chopped do
                # Same product or less
                {list, largest}
            else
                v = product(list)
                if v > largest do
                    # New highest
                    {list, v}
                else
                    {list, largest}
                end
            end
        end)
    end

    # Less code, but actually more work
    def less_code() do
        numbers = Read.get_digits
        0..length(numbers) |> Enum.reduce(0, fn c, a ->
            p = Read.get_digits |> Enum.drop(c) |> Enum.take(13) |> product
            if p > a, do: p, else: a
        end)
    end

    def product(list) do
        list |> Enum.reduce(1, fn n, acc ->
            acc * n
        end)
    end
end

# 23514624000
{_, ans} = Bruteforce.largest_product
IO.puts inspect(ans)