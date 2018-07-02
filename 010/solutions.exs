require Integer
defmodule Factors do
    def brute_number_of_factors(n) do
        top = trunc(:math.sqrt(n))
        acc = 1..top |> Enum.reduce_while(0, fn i, total ->
            if total > 2 do
                {:halt, total}
            else
                if rem(n, i) == 0 do
                    o = div(n, i)
                    if o == i do
                        {:cont, total + 1}
                    else
                        {:cont, total + 2}
                    end
                else {:cont, total}
                end
            end
        end)
        acc
    end
end

# 142913828922
ans = 1..2000000
|> Enum.filter(& Integer.is_odd(&1))
|> Enum.filter(& Factors.brute_number_of_factors(&1) == 2) 
|> Enum.sum
IO.puts inspect(ans + 2)