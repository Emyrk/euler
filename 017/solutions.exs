# Places and their names
defmodule Lookup do 
    @ones %{
        0 => "zero",
        1 => "one",
        2 => "two",
        3 => "three",
        4 => "four",
        5 => "five",
        6 => "six",
        7 => "seven",
        8 => "eight",
        9 => "nine",
        10 => "ten"
    }
    def ones_data, do: @ones

    @tens %{
        0 => "",
        10 => "ten", # HOW
        20 => "twenty",
        30 => "thirty",
        40 => "forty",
        50 => "fifty",
        60 => "sixty",
        70 => "seventy",
        80 => "eighty",
        90 => "ninety",
    }
    def tens_data, do: @tens


    @hundreds %{
        0 => "",
        100 => "one hundred",
        200 => "two hundred",
        300 => "three hundred",
        400 => "four hundred",
        500 => "five hundred",
        600 => "six hundred",
        700 => "seven hundred",
        800 => "eight hundred",
        900 => "nine hundred"
    }
    def hundreds_data, do: @hundreds
end

# Counting letters for each number
defmodule BruteForce do
    def letters(n) when n == 1000 do
        "one thousand"
    end


    def letters(n) do
        h = hundreds(n)
        t = tens(n)
        o = ones(n)

        # Ones place
        # Lookup.ones_data[n]
        combine_hundreds_tens(h, combine_tens_ones(t, o))
    end

    def combine_hundreds_tens(h, t) do
        cond do
            h != "" && t == "zero" ->
                h
            h != "" && t != "" ->
                h <> " and " <> t
            true -> 
                h <> t
        end
    end

    def combine_tens_ones(t, o) do
        cond do
            t == "ten" ->
                case o do
                    "zero" -> "ten"
                    "one" -> "eleven"
                    "two" -> "twelve"
                    "three" -> "thirteen"
                    "five" -> "fifteen"
                    "eight" -> "eighteen"
                    "" -> "ten"
                    _ ->
                        o <> "teen"
                end
            t != "" && o == "zero" ->
                t
            t != "" && o != "" ->
                t <> "-" <> o
            true ->
                t <> o

        end
    end

    def hundreds(n) do
        n = div(n, 100) * 100
        Lookup.hundreds_data[n]
    end

    def tens(n) do
        v = rem(n, 100) # 11, 21
        n = div(v, 10) * 10 # 10, 20, 30

        Lookup.tens_data[n]
    end

    def ones(n) do
        n = rem(n, 10) # 11, 21
        Lookup.ones_data[n]
    end

    def letter_count(n) do
        letters(n) |> count_alpha
    end

    def count_alpha(str) do
        str |> String.graphemes |> Enum.count(& &1 != " " && &1 != "-")
    end
end


# Test the implementation
# 1) Start ExUnit.
ExUnit.start()

# 2) Create a new test module (test case) and use "ExUnit.Case".
defmodule AssertionTest do
  # 3) Notice we pass "async: true", this runs the test case
  #    concurrently with other test cases. The individual tests
  #    within each test case are still run serially.
    use ExUnit.Case, async: true

  # 4) Use the "test" macro instead of "def" for clarity.
    test "words" do
        assert BruteForce.letters(1) == "one"
        assert BruteForce.letters(2) == "two"
        assert BruteForce.letters(3) == "three"
        assert BruteForce.letters(4) == "four"
        assert BruteForce.letters(342) == "three hundred and forty-two"
        assert BruteForce.letter_count(342) == 23
        assert BruteForce.letters(115) == "one hundred and fifteen"
        assert BruteForce.letter_count(115) == 20
        assert BruteForce.letters(394) == "three hundred and ninety-four"
        assert BruteForce.letter_count(394) == 25

        assert BruteForce.letters(208) == "two hundred and eight"

        assert BruteForce.letters(152) == "one hundred and fifty-two"

        assert BruteForce.letters(10) == "ten"
        assert BruteForce.letters(11) == "eleven"
        assert BruteForce.letters(12) == "twelve"
        assert BruteForce.letters(13) == "thirteen"
        assert BruteForce.letters(14) == "fourteen"
        assert BruteForce.letters(15) == "fifteen"
        assert BruteForce.letters(16) == "sixteen"
        assert BruteForce.letters(17) == "seventeen"
        assert BruteForce.letters(18) == "eighteen"
        assert BruteForce.letters(19) == "nineteen"
        assert BruteForce.letters(58) == "fifty-eight"
        assert BruteForce.letters(79) == "seventy-nine"

        assert BruteForce.letter_count(10) == BruteForce.count_alpha("ten")
        assert BruteForce.letter_count(11) == BruteForce.count_alpha("eleven")
        assert BruteForce.letter_count(12) == BruteForce.count_alpha("twelve")
        assert BruteForce.letter_count(13) == BruteForce.count_alpha("thirteen")
        assert BruteForce.letter_count(14) == BruteForce.count_alpha("fourteen")
        assert BruteForce.letter_count(15) == BruteForce.count_alpha("fifteen")
        assert BruteForce.letter_count(16) == BruteForce.count_alpha("sixteen")
        assert BruteForce.letter_count(17) == BruteForce.count_alpha("seventeen")
        assert BruteForce.letter_count(18) == BruteForce.count_alpha("eighteen")
        assert BruteForce.letter_count(19) == BruteForce.count_alpha("nineteen")
        assert BruteForce.letter_count(58) == BruteForce.count_alpha("fiftyeight")
        assert BruteForce.letter_count(79) == BruteForce.count_alpha("seventynine")

        assert 1..9 |> Enum.map_every(1, &BruteForce.letter_count/1) |> Enum.sum == 36
        assert 10..19 |> Enum.map_every(1, &BruteForce.letter_count/1) |> Enum.sum == 70
        assert 20..99 |> Enum.map_every(1, &BruteForce.letter_count/1) |> Enum.sum == 748
        assert 1..99 |> Enum.map_every(1, &BruteForce.letter_count/1) |> Enum.sum == 854
        assert 100..999 |> Enum.map_every(1, &BruteForce.letter_count/1) |> Enum.sum == 20259

    end
end


# 21124
IO.puts 1..1000 |> Enum.map_every(1, &BruteForce.letter_count/1) |> Enum.sum