defmodule Problem do
    def factored(list, _) when list == [] do
        false
    end

    # If the list contains numbers that can be multiplied to
    # obtain n, it will return true
    def factored(list, n) do
        [ head | rest] = list
        if can_product(head, rest, n) do
            true
        else
            factored(rest, n)
        end
    end

    def can_product(next, _, n) when next > n do
        false
    end

    def can_product(next, _, n) when div(n, next) == 1 and rem(n, next) == 0 do
        true
    end

    def can_product(next, rest, n) when rest == [] do
        if rem(n, next) == 0 and div(n, next) == next do
            true
        else
            false
        end
    end

    def can_product(next, rest, n) when rem(n, next) != 0  and next != 1 do
        [ next | rest ] = rest
        can_product(next, rest, n)
    end

    # def can_product(next, _, n) when div(n, next) == 1 do
    #     true
    # end

    def can_product(next, _, _) when next == 1 do
        false
    end

    def can_product(next, rest, n) do
        # This is called when it is divisible, we need to try it
        # With the number repeated, and without it repeated
        r = div(n, next)
        [ new_next | new_rest ] = rest
        # IO.puts inspect(r) <> " " <> inspect(rest) <> " " <> inspect(next)
        if can_product(next, rest, r) do
            true
        else
            can_product(new_next, new_rest, r)
        end
    end

    def test() do
        IO.puts Problem.factored([2, 3], 4) == true
        IO.puts Problem.factored([2, 3, 4], 8) == true
        IO.puts Problem.factored([2, 3, 4], 23) == false
        IO.puts Problem.factored([2, 3, 4, 5, 6, 7, 8], 8) == true
        IO.puts Problem.factored([2, 3, 4, 5, 10], 20000) == true
    end

    # We know the factors are 1-499. We will have to test each factor if itself is a factor
    def factor_list(n) do
        2..n
        |> Enum.reduce([], fn n, list ->
            IO.puts inspect(n) <> " " <> inspect(list)
            if factored(list, n), do: list, else: list ++ [n]
        end)
    end

    def product(list) do
        list |> Enum.reduce(1, fn n, acc ->
            acc * n
        end)
    end
end



answer = Problem.factor_list(255) |> Problem.product


# 1..500 |> Enum.each(& IO.puts inspect(&1) <> " - " <> inspect(rem(answer, &1)))