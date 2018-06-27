defmodule Util do
    def log2(n) do
        :math.log(n)/:math.log(2)
    end
end

# Trim takes a list of numbers and performs the function
# described in the problem statement to determine the last item remaining.
#   This is the slow, but correct method to test other impementations.
defmodule Trim do
    def trim_list_n(n) do
        trim_list_size(Enum.to_list(1..n),n)
    end

    def trim_list(list) do
        trim_list_size(list, length(list))
    end

    def trim_list_size(list, size) do
        trim(list, trunc(:math.log(size)/:math.log(2)) + 1)
    end

    def trim(list, times_left) when times_left == 1 do
        [ head | _ ] = list
        head
    end

    def trim(list, times_left) do
       list = list |>  Enum.drop_every(2) |> Enum.reverse
       trim(list, times_left - 1)
    end
end

# Actually solving S(n)
defmodule Problem do
    # Twice as quick as s_option_1
    #   To check
    #   1..1000 |> Enum.each(&(IO.puts inspect(Problem.s(&1) - Problem.s_option_1(&1))))
    def s(n) do
        sum = 1..n |> Enum.filter(&(rem(&1, 2) == 0)) |> Enum.reduce(0, fn n, acc ->
            acc + p(n)
        end)
        sum = sum * 2
        case rem(n, 2) do
            0 -> sum - p(n) + 1# Even
            1 -> sum + 1
        end
    end

    # Brute force
    def s_option_1(n) do
        1..n |> Enum.reduce(0, fn n, acc ->
            acc + p(n)
        end)
    end

    # Using the known patterns
    #   - Every odd is P(n-1) (these are filtered out anyway)
    #   - Every 4th is P(n-1) + 2
    #   - Every 8th is P(n-1) - 2
    #   
    #   [ C, S, C, S]
    #
    #   To check
    #   1..100 |> Enum.each(&(IO.puts inspect(Problem.s(&1) - Problem.s_pattern(&1))))
    def s_pattern(n) do
        { _, sum } = 1..n 
        |> Enum.filter(&(rem(&1, 2) == 0)) 
        |> Enum.reduce({0, 0}, fn n, state ->
            {prev, acc} = state
            p = p_pattern(prev, n)
            {p, acc + p}
        end)

        sum = sum * 2 # We are only using half the n's
        case rem(n, 2) do
            0 -> sum - p(n) + 1# Even
            1 -> sum + 1
        end
    end

    # The beginning are kinda exceptions because there is no prev set
    def p_pattern(prev_p, n) when n < 5 do
        p(n)
    end

    # All odd n's are the same as the previous P(n)
    def p_pattern(prev_p, n) when rem(n, 2) == 1 do
        prev_p
    end

    # Every 4th is just the previous + 2
    def p_pattern(prev_p, n) when rem(n, 4) == 2 do
        prev_p + 2
    end

    # Every time floor(div, 4) == odd
    def p_pattern(prev_p, n) when rem(div(n, 4), 2) == 1 do
        prev_p - 2
    end

    def p_pattern(prev_p, n) do
        p(n)
    end

    # Brute force p
    def p(n) do
        Trim.trim_list_n(n)
    end
end

defmodule Props do
    def min_p(n) do 
        :math.pow(2, trunc(Util.log2(n)) - 1)
    end

    def max_p(n) do
        :math.pow(2, trunc(Util.log2(n)))
    end
end

num = 10
range = trunc(:math.pow(2, num))..trunc(:math.pow(2, num+1)-1)
#  range = 1..200

# IO.puts range
# |> Enum.filter(&(rem(&1, 2) == 0)) 
# |> Enum.each(
#     &(IO.puts "n = " <> inspect(&1) <> ": p = " <> inspect(Trim.trim_list_n(&1)) <> "  |  log2(n) = " <> inspect(trunc(Util.log2(&1))) <> "  (" <>
#     inspect(:math.pow(2, trunc(Util.log2(&1)) - 1)) <>
#     " / " <>
#     inspect(:math.pow(2, trunc(Util.log2(&1)))) <>
#     " / " <>
#     inspect(:math.pow(2, trunc(Util.log2(&1) + 1))) <> ")" <>
#     "  --" <>
#     inspect(rem(&1, 4)))
# )
# |> Enum.reduce(0, fn n, acc ->
#     acc + Trim.trim_list_n(n)
# end)


# Determine the number of times the max bound is hit
# 1..12 |> Enum.each(fn num ->
#         range = trunc(:math.pow(2, num))..trunc(:math.pow(2, num+1)-1)
#         IO.puts inspect(range) <> " -> " <> inspect(range
#         # |> Enum.filter(&(rem(&1, 2) == 0)) 
#         |> Enum.count(&(
#         Trim.trim_list_n(&1) == :math.pow(2, trunc(Util.log2(&1)))
#         )))
#     end
# )

# Sum
{_, full_sums} = 1..1 |> Enum.reduce({0, []}, fn num, acc ->
        {running, list} = acc
        range = trunc(:math.pow(2, num))..trunc(:math.pow(2, num+1)-1)
        sum = range
        |> Enum.filter(&(rem(&1, 2) == 0)) 
        |> Enum.reduce(0, fn n, acc ->
            acc + Trim.trim_list_n(n)
        end
        )

        running = running + sum * 2
        IO.puts inspect(range) <> " -> S(" <> inspect(trunc(:math.pow(2, num+1)-1)) <> ") = " <> inspect(running) <> "  | max: " <> inspect(Props.max_p(:math.pow(2, num)))
        {running, list ++ [running]}
    end
)


# full_sums = [4, 12, 56, 176, 864, 2752, 13696, 43776, 218624, 699392, 3495936, 11186176, 55926784, 178962432]
ev_4th_sum = [0, 2, 12, 40, 208, 672, 3392, 10880, 54528, 174592, 873472, 2795520]

full_sums |> Enum.reverse |> Enum.reduce(1, fn cur, prev ->
    unless cur == 0, do: IO.puts inspect(prev / cur)
    cur # Pass the current to next
end)

IO.puts inspect(full_sums)
# IO.puts inspect(sums |> Enum.map(&(&1/4)))


# Some lists for shell work
defmodule FixedLists do
    def log(), do: Enum.to_list(1..12)
    def four(), do: [4, 16, 64, 256, 1024, 4096, 16384, 65536, 262144, 1048576, 4194304, 16777216]
    def sn(), do: [4, 16, 72, 248, 1112, 3864, 17560, 61336, 279960, 979352, 4475288, 15661464]

    def dif(list1, list2) do
        [h1 | t1] = list1
        [h2 | t2] = list2

        if t1 == [] do
            IO.puts h2-h1
        else
            IO.puts h2-h1
            dif(t1, t2)
        end
    end
end

# Range is 1024..2047
# p range is 512 to 1024
# log2(n) == 10 -> Sum = 43776
# 1024 answer is hit 4 times


# Range is 256..511
# p range is 128 to 256
# log2(n) == 8 -> Sum = 43776
# Top is hit 8 times

# Range is 128..255
# p range is 64 to 126
# log2(n) == 7 -> Sum = 13696
# Top hit 8 times

# Range is 64..127
# p range is 32 to 64
# log2(n) == 6 -> Sum = 2752
# Top hit 4 times


# Top val hits:
# 2..3 -> 1
# 4..7 -> 1
# 8..15 -> 2
# 16..31 -> 2
# 32..63 -> 4
# 64..127 -> 4
# 128..255 -> 8
# 256..511 -> 8
# 512..1023 -> 16
# 1024..2047 -> 16
# 2048..4095 -> 32
# 4096..8191 -> 32
