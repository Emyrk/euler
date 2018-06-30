defmodule Factors do
    def brute_number_of_factors(n) do
        top = trunc(:math.sqrt(n))
        acc = 1..top |> Enum.reduce({[], 0}, fn i, acc ->
            {list, total} = acc
            if rem(n, i) == 0 do
                o = div(n, i)
                if o == i do
                    {[i] ++ list, total + 1}
                else
                    {[i, o] ++ list, total + 2}
                end
            else {list, total}
            end
        end)
        acc
    end

    def largest_prime_factor(n) do
        {list, _} = brute_number_of_factors(n)
        ans = list |> Enum.filter(fn i ->
            {_, factors} = brute_number_of_factors(i)
            factors == 2
        end)
        |> Enum.max
        ans
    end

    def test() do
    end
end

# This is not efficient, but eh
# 6857
IO.puts largest_prime_factor(600851475143)

