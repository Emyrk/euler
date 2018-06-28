defmodule Util do
    def log2(n) do
        :math.log(n)/:math.log(2)
    end

    def goto(), do: trunc(10.0e18)
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
    def s(n) do
        s(1, n)
    end

    def m_t(n) do 
        rem(trunc(n), mod_a())
    end

    def mod_a() do
        987654321
    end

    def stolen_s(n) when n == 0 do
        0
    end

    def stolen_s(n) when n == 1 do
        1
    end

    def stolen_s(n) when n == 2 do
        3
    end

    def stolen_s(n)  when n == 3 do
        5
    end

    def stolen_s(n) do
        x = div(n, 4)        
        ret = m_t(stolen_s(x - 1) * 16) - m_t((x - 1) * 4) + 5
        y = x * 4
        acc = y..n |> Enum.reduce(ret, fn i, acc ->
            acc + m_t(p(i))
        end)
        rem(acc + mod_a, mod_a)
    end

    # Twice as quick as s_option_1. This is always correct
    #   To check
    #   1..1000 |> Enum.each(&(IO.puts inspect(Problem.s(&1) - Problem.s_option_1(&1))))
    def s(n1, n2) do
        case n2 do
        # Shortcuts for comparing
        1000 -> 268271
        5000 -> 5981871
        10000 -> 26096543
        20000 -> 95665775
        _ ->
            sum = n1..n2 |> Enum.filter(&(rem(&1, 2) == 0)) |> Enum.reduce(0, fn n, acc ->
                acc + p(n)
            end)
            sum = sum * 2
            case rem(n2, 2) do
                0 -> sum - p(n2) + 1# Even
                1 -> sum + 1
            end
        end
    end


    # Problem.s_e_l(4294967296, 8589934591, 2147483648)
    # 4294967296..8589934591 |> Enum.filter(&(rem(&1, 2147483648) == 0))

   # Returns {S(n), last}
    def s_e_l(n1, n2, r) when rem(n1, r) == 0 do
        last = p(n1 + r)
        {p(n1) + last, last}
        # n1..n2 |> Enum.filter(&(rem(&1, r) == 0)) |> Enum.reduce({0, 0}, fn n, acc ->
        #     {sum, last} = acc
        #     v = p(n)
        #     {sum + v, v}
        # end)
    end

    # Returns {S(n), last}
    def s_e_l(n1, n2, r) do
            n1..n2 |> Enum.filter(&(rem(&1, r) == 0)) |> Enum.reduce({0, 0}, fn n, acc ->
                {sum, last} = acc
                v = p(n)
                {sum + v, v}
            end)
    end

    def s_e(n1, n2, r) do
            sum = n1..n2 |> Enum.filter(&(rem(&1, r) == 0)) |> Enum.reduce(0, fn n, acc ->
                acc + p(n)
            end)
            sum
            # sum = sum * 2
            # case rem(n, 2) do
            #     0 -> sum - p(n) + 1# Even
            #     1 -> sum + 1
            # end
    end

    def s_option_1(n) do
        s_option_1(1, n)
    end

    # Brute force
    def s_option_1(n1, n2) do
        n1..n2 |> Enum.reduce(0, fn n, acc ->
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
    def p_pattern(_, n) when n < 17 do
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

    # Every 16th with rem 8 is just the previous + 6
    def p_pattern(prev_p, n) when rem(n, 16) == 8 do
        prev_p + 6
    end

    # Every 32nd is just the previous + 10
    #   64 is an exception... for some reason
    def p_pattern(prev_p, n) when rem(div(n, 16), 2) == 1 and n != 64 do
        prev_p - 10
    end

    # Every 64nd is just the previous + 22
    #   64 is an exception... for some reason
    def p_pattern(prev_p, n) when rem(div(n, 32), 2) == 1 and n > 64 do
        prev_p + 22
    end

    # Every 64nd is just the previous - 42
    def p_pattern(prev_p, n) when n > 384 and rem(div(n, 64), 2) == 1 do
        prev_p - 42
    end

    def p_pattern(prev_p, n) when n > 400 and rem(div(n, 128), 2) == 1 do
        prev_p + 86
    end

    def p_pattern(prev_p, n) when n > 400 and rem(div(n, 256), 2) == 1 do
        prev_p - 170
    end


    def p_pattern(prev_p, n) do
        v = p(n)
        dif = v - prev_p
        IO.puts "Calc " <> inspect(n) <> " : p = " <> inspect(prev_p) <> " v = " <> inspect(v) <> "  " <> inspect(dif)
        if dif != 0, do: IO.puts "  -> " <> inspect(div(n, 32))
        
        v
    end

    def s_dyn_pattern(n) do
        s_dyn_pattern(1, n, 0)
    end

    def s_dyn_pattern(n1, n2) do
        s_dyn_pattern(n1, n2, p(n1 - 1))
    end

    def s_dyn_pattern(n1, n2, last) when n1 >= n2 do
        0
    end

    # DYNAMIC PATTERN!
    #   If n is divisible by 2^x and odd, then alternate the addition/subtraction of the previous difference number.
    #   The difference is (prev_dif - 1) * 2
    #   To check
    #   1..100 |> Enum.each(&(IO.puts inspect(Problem.s(&1) - Problem.s_dyn_pattern(&1))))
    #   n1 MUST be on a power of 2 boundry
    def s_dyn_pattern(n1, n2, last) do
        diflist = diflist()
        powerlist = powerlist()
        { _, sum } = n1..n2 
        |> Stream.filter(&(rem(&1, 2) == 0)) 
        |> Enum.reduce({last, 0}, fn n, state ->
            {prev, acc} = state
            p = p_pattern_dynamic(powerlist, diflist, prev, n)
            {p, rem(acc + p, 987654321)}
        end)

        sum = sum * 2 # We are only using half the n's
        case rem(n2, 2) do
            0 -> sum - p(n2)# Even
            1 -> sum
        end
    end

    def s_chunks(n) when n < 64 do
        s_dyn_pattern(n)
    end

    # Build chunks of sets to sum together. 
    def s_chunks(n) do
        diflist = s_diflist()
        powerlist = powerlist()
        # We will have to manually add anything after the last element
        ln = trunc(Util.log2(n))
        # Chunks will start after 63
        # acc = {sum, last, }
        {running, bot} = 8..ln |> Enum.reduce({s(127), p(127)}, fn i, acc ->
            # The acc will have {S(n), last}
            # Do each chunk
            r =  trunc(:math.pow(2, i-2)) 
            n = :math.pow(2, i)
            bot = trunc(Props.min_p(n))
            top = trunc(Props.max_p(n)) - 1

            # Now when solving, you don't need to calculate each value
            {sum_off, last} = s_e_l(bot, top, r)
            idx = trunc(i / 2) - 4
            {_, dr} = Enum.fetch(diflist, idx)
            dif = dr * r
            sum = rem((sum_off*r), 987654321) + rem(dif, 987654321)
            {running, _} = acc

            IO.puts "(" <> to_string(bot) <> ", " <> to_string(top) <> ") r = " <> inspect(r) <> " sum = "  <> inspect(sum) <> 
            " dif = " <> inspect(dif) <> " running = " <> inspect(running) 
            {rem(running + sum, 987654321) , top}
        end)

        next_sum = s_dyn_pattern(bot, n)
        running = running + next_sum
        rem(running, 987654321)
        
    end

    def powerlist(), do: 5..1000 |> Enum.map(&(trunc(:math.pow(2, &1))))
    def diflist() do
        start = []
        {list, _ } = (4..1000 |> Enum.map_reduce(-10, fn _, p_dif ->
            d = trunc(((p_dif*-1) + 1) * 2)
            {d, d}
        end))
        start ++ list
    end

    def s_diflist() do
        diflist() |> Enum.filter(&(&1 < 0)) |> Enum.map(&(abs(&1)))
    end

    # 1000..5000 |> Enum.each(&(IO.puts Problem.p_pattern_dynamic(Problem.p(&1-1), &1) - Problem.p(&1)))
    def p_pattern_dynamic(prev, n) do 
        p_pattern_dynamic(powerlist(), diflist(), prev, n)
    end

    def p_pattern_dynamic(_powerlist, _diflist, _prev, n) when n < 17 do
        p(n)
    end

    def p_pattern_dynamic(_powerlist, _diflist, prev, n) when rem(n, 2) == 1 do
        prev
    end

    # Every 4th is just the previous + 2
    def p_pattern_dynamic(_powerlist, _diflist, prev, n) when rem(n, 4) == 2 do
        prev + 2
    end

    # Every time floor(div, 4) == odd
    def p_pattern_dynamic(_powerlist, _diflist, prev, n) when rem(div(n, 4), 2) == 1 do
        prev - 2
    end

    # Every 16th with rem 8 is just the previous + 6
    def p_pattern_dynamic(_powerlist, _diflist, prev, n) when rem(n, 16) == 8 do
        prev + 6
    end

    # Every 32nd is just the previous + 10
    #   64 is an exception... for some reason
    def p_pattern_dynamic(_powerlist, _diflist, prev, n) when rem(div(n, 16), 2) == 1 and n != 64 do
        prev - 10
    end

    def p_pattern_dynamic(powerlist, diflist, prev, n) do
        [p_head | p_tail] = powerlist
        [d_head | d_tail] = diflist
        if p_head == [] do
            p(n)
        else
            p = p_pattern_check(p_head, d_head, prev, n)
            if p == 0 do
                p_pattern_dynamic(p_tail, d_tail, prev, n)
            else
                p
            end
        end

    end

    def p_pattern_check(power, dif, prev, n) when n < power * 2 do
        p(n)
    end

    def p_pattern_check(power, dif, prev, n) do
        if rem(div(n, power), 2) == 1, do: prev + dif, else: 0
    end

    def p(n) when n == 1 do
        1
    end

    def p(n) when n == 2 or n == 3 do
        2
    end

    def p(n) do
        x = div(n, 4)
        ret = p(x) * 4
        if rem(n, 4) < 2, do: ret - 2, else: ret
    end

    # Brute force p
    def brute_p(n) do
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
# {_, full_sums} = 1..1 |> Enum.reduce({0, []}, fn num, acc ->
#         {running, list} = acc
#         range = trunc(:math.pow(2, num))..trunc(:math.pow(2, num+1)-1)
#         sum = range
#         |> Enum.filter(&(rem(&1, 2) == 0)) 
#         |> Enum.reduce(0, fn n, acc ->
#             acc + Trim.trim_list_n(n)
#         end
#         )

#         running = running + sum * 2
#         IO.puts inspect(range) <> " -> S(" <> inspect(trunc(:math.pow(2, num+1)-1)) <> ") = " <> inspect(running) <> "  | max: " <> inspect(Props.max_p(:math.pow(2, num)))
#         {running, list ++ [running]}
#     end
# )


# full_sums = [4, 12, 56, 176, 864, 2752, 13696, 43776, 218624, 699392, 3495936, 11186176, 55926784, 178962432]
ev_4th_sum = [0, 2, 12, 40, 208, 672, 3392, 10880, 54528, 174592, 873472, 2795520]

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


# Get s_list
# 1..500 |> Enum.each(&(
#     IO.puts "S(" <> inspect(&1) <> ") = " <> inspect(Problem.s_pattern(&1)) <> " - " <> inspect(trunc(Util.log2(&1)))
# ))


# 1..500 
# |> Enum.map(&(Problem.s_pattern(&1))) # Now a list of S(n)
# |> Enum.reduce(0, fn sn, prev ->
#     IO.puts inspect(sn - prev)
#     sn
# end)


# THE PROBLEM
# IO.puts rem(Problem.s_chunks(trunc(10.0e+18)), 987654321)
#


# list = 1..3000 |> Enum.map(&(Problem.s_dyn_pattern(&1) - Problem.s_16(&1) * 16))
# Enum.reduce(list, 0, fn n, p ->
#     IO.puts n - p
#     n
# end)

# 8..10|> Enum.each(&(Sh.dif(&1)))
defmodule Sh do
    def dif(i) do
        n = :math.pow(2, i)
        r =  trunc(:math.pow(2, i-2)) #2 * (trunc(Util.log2(n) - 1))

        d = dif(trunc(Props.min_p(n)), trunc(Props.max_p(n)) - 1, r)
                IO.puts to_string(Props.min_p(n)) <> " " <>
        to_string(trunc(Props.max_p(n)) -  1) <> " " <>
        to_string(r) <> " i = " <> inspect(i) <> " r = " <> inspect(r) <> " d = " <> inspect(d) <> " d/r = " <> inspect(d/r)
        d
    end

    def dif(n1, n2, r) do
        # IO.puts Problem.s_e(n1,n2,r)
        Problem.s_option_1(n1, n2) - Problem.s_e(n1,n2,r) * r
    end
end

defmodule PlotP do
    def print_p(n) do
        n = :math.pow(2, n)
        bot = trunc(Props.min_p(n))
        top = trunc(Props.max_p(n)) - 1

        f = File.open!("out.dat", [:read, :write])
        IO.puts "Section: (" <> inspect(bot) <> ", " <> inspect(top) <> ")"
        bot..top |> Enum.filter(&(rem(&1, 2) == 0)) |>Enum.each(fn n ->
            str =  inspect(n) <> "  " <> inspect(Problem.p(n)) <> "\n"
            IO.puts str
            IO.write f, str
        end)
        File.close(f)
    end

end