# Bruteforce!
defmodule BruteForce do
    def nth_prime(n) do
        nth_prime(2, 0, n)
    end

    def nth_prime(c, count, stop) when stop == count do
        c - 1
    end

    def nth_prime(c, count, stop) do
        if number_of_factors(c) == 2 do
            nth_prime(c + 1, count + 1, stop)
        else
            nth_prime(c + 1, count, stop)
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

    def number_of_factors(n, mult) when rem(n, 2) == 1 and mult == 0 do
        brute_number_of_factors(n)
    end

    def number_of_factors(n, mult) when rem(n, 2) == 1 and mult <= 2 do
        brute_number_of_factors(trunc(n * :math.pow(2, mult)))
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

# 104743
IO.puts BruteForce.nth_prime(10001)

