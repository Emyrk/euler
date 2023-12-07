defmodule Pull do
  @regexString Regex.compile!("Game [0-9]+: (.*)")
  @regexRed Regex.compile!("([0-9]+) red")
  @regexBlue Regex.compile!("([0-9]+) blue")
  @regexGreen Regex.compile!("([0-9]+) green")
  # array of ints, rgb
  defstruct red: 0, green: 0, blue: 0

  def parseGames(text) do
    [_, pullText] = Regex.run(@regexString, text)

    # 1 game of multiple pulls
    pullText
    |> String.split(";")
    |> Enum.map(fn pull ->
      %Pull{
        red: get_count(@regexRed, pull),
        green: get_count(@regexGreen, pull),
        blue: get_count(@regexBlue, pull)
      }
    end)
    |> Enum.reduce(%Pull{}, fn pull, acc ->
      %Pull{
        red: max(pull.red, acc.red),
        green: max(acc.green, pull.green),
        blue: max(acc.blue, pull.blue)
      }
    end)
  end

  def get_count(regexString, pull) do
    v = Regex.run(regexString, pull)

    case v do
      nil ->
        0

      _ ->
        [_, count] = v
        String.to_integer(count)
    end
  end
end

out =
  File.stream!("input.txt")
  |> Enum.to_list()
  |> Enum.map(&String.trim(&1, "\n"))
  |> Enum.map(&Pull.parseGames/1)
  |> Enum.with_index()
  |> Enum.reduce(0, fn {pull, index}, acc ->
    # IO.puts("#{inspect(pull)}, #{pull.red <= 12}, #{pull.green <= 13}, #{pull.blue <= 14}")

    acc + index

    cond do
      pull.red <= 12 and pull.green <= 13 and pull.blue <= 14 ->
        acc + (index + 1)

      true ->
        acc
    end
  end)

# part 1
IO.puts("Part 1 #{inspect(out)}")

# part 2
out =
  File.stream!("input.txt")
  |> Enum.to_list()
  |> Enum.map(&String.trim(&1, "\n"))
  |> Enum.map(&Pull.parseGames/1)
  |> Enum.map(fn pull ->
    max(pull.red, 1) * max(pull.green, 1) * max(pull.blue, 1)
  end)
  |> Enum.sum()

IO.puts("Part 2 #{inspect(out)}")
