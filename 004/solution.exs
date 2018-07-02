defmodule Palindrome do
    def is_palidrome(n) do
        digits = Integer.digits(n)
        len = round(length(digits)/2)
        lists = Enum.split(digits, len)
        { l1, l2 } = lists
        l2 = Enum.reverse(l2)
        is_palidrome_rec(l1, l2)
    end

    def is_palidrome_rec(_, l2) when l2 == [] do
        true
    end

    def is_palidrome_rec(l1, l2) do
        [h1 | r1] = l1
        [h2 | r2] = l2
        # IO.puts inspect(h1) <> " " <> inspect(h2)
        if h1 != h2, do: false, else: is_palidrome_rec(r1, r2)
    end
end

defmodule BruteForce do
    # Largest palindrome made from product of n digit numbers
    def largest_palindrome(n) do
        low = trunc(:math.pow(10, n-1))
        high = trunc(:math.pow(10, n)) - 1

        low..high
        |> Enum.reduce(0, fn i, largest ->
            high..i |> Enum.reduce(largest, fn j, largest ->
                v = i * j
                if Palindrome.is_palidrome(v) and v > largest, do: v, else: largest
            end)
        end)
    end
end

# 906609
IO.puts BruteForce.largest_palindrome(3)