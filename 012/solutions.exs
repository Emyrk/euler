# Bruteforce!
defmodule BruteForce do

    # Given an odd number 'n', tells you at which power of 2 multiplied
    # against n is required to get f factors.
    def when_n_factors(n, f) do 
        factor_n = brute_number_of_factors(n)
        factor_n2 = brute_number_of_factors(n*2)
        step_one = factor_n2 - factor_n
        step_two = brute_number_of_factors(n*2*2) - factor_n2

        need = f - factor_n
        per2 = step_one + step_two
        # IO.puts "__" <> inspect(need) <> " " <> inspect(per2)
        pow = (need / per2) * 2
        if pow - trunc(pow) == 0 do
            trunc(n * :math.pow(2, trunc(pow)))
        else
            trunc(n * :math.pow(2, trunc(pow)+1))
        end
    end

    # Cycles through odd numbers trying to find the first number that 
    # gets to f factors.
    def first_to_f_factors(f) do
        1..5000000 
        |> Enum.filter(& rem(&1, 2) == 0) 
        |> Enum.reduce(-1, fn n, lowest ->
            ans = when_n_factors(n, f)
            if lowest == -1 or ans < lowest, do: ans, else: lowest
        end)
    end

    # The euler problem
    def first_triangle_to_f_factors(f) do
        first_triangle_to_f_factors(1, 2, f)
    end

    defp first_triangle_to_f_factors(c, n, f) do
        if number_of_factors(c) > f do
            c
        else
            first_triangle_to_f_factors(c + n, n + 1, f)
        end
    end


    def number_of_factors(n) do
        log2 = :math.log(n)/:math.log(2)
        if  log2 - trunc(log2) == 0 do
            if rem(trunc(log2), 2) == 1 do
                trunc(log2) + 1
            else
                trunc(log2) + 2
            end
        else
            number_of_factors(n, 0)
        end
    end

    def number_of_factors(n, mult) when rem(n, 2) == 1 do
        factor_n = brute_number_of_factors(n)
        factor_n2 = brute_number_of_factors(n*2)
        step_one = factor_n2 - factor_n
        step_two = brute_number_of_factors(n*2*2) - factor_n2
        steps = step_two - step_one
        # IO.puts inspect(n) <> " " <> inspect step_two + step_one
        case steps do
            0 -> 
                # Both steps are the same
                factor_n + (step_one * mult)
            _ ->
                sec = div(mult, 2)
                fir = mult - sec
                factor_n + (fir * step_one) + (sec * step_two)
        end
    end

    def number_of_factors(n, mult) do
        number_of_factors(div(n, 2), mult+1)
    end

    def brute_number_of_factors(n) do
        top = trunc(:math.sqrt(n))
        acc = 1..top |> Enum.reduce(0, fn i, acc ->
            if rem(n, i) == 0, do: acc + 1, else: acc
        end)
        acc * 2
    end

    def first_to_n_factors(n) do
        min = trunc(:math.pow((n/2), 2))
        recurse(min, n)
    end

    def recurse(next, n) do
        if number_of_factors(next) >= n do
            next
        else
            recurse(next + 1, n)
        end
    end

    def test() do
        1..10000 |> Enum.each(fn n ->
            if number_of_factors(n) - brute_number_of_factors(n) != 0, do: IO.puts("Wrong: " <> inspect(n))
        end)
    end
end

# 76576500
IO.puts first_triangle_to_f_factors(500)