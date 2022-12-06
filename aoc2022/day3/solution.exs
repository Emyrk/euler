defmodule Letter do
  # Capital Letters
  def value(a) when a < "a" do
    <<aacute::utf8>> = a
    aacute - ?A + 27
  end

  def value(a) do
    <<aacute::utf8>> = a
    aacute - ?a + 1
  end
end

# Part 1
sacks =
  File.stream!("input.txt")
  |> Enum.to_list()
  |> Enum.map(&String.trim(&1, "\n"))
  |> Enum.map(fn line ->
    letters =
      String.graphemes(line)
      |> Enum.chunk_every(round(String.length(line) / 2))
  end)
  |> Enum.map(fn [a, b] ->
    c = a -- b
    common = a -- c
    Enum.uniq(common)
  end)
  |> Enum.map(fn [a] ->
    Letter.value(a)
  end)
  |> Enum.sum()

IO.puts("Part 1: #{sacks}")

# Part 2

groups =
  File.stream!("input.txt")
  |> Enum.to_list()
  |> Enum.map(&String.trim(&1, "\n"))
  |> Enum.map(fn line ->
    String.graphemes(line)
  end)
  |> Enum.chunk_every(3)
  |> Enum.map(fn [a, b, c] ->
    Enum.filter(a, fn x ->
      Enum.member?(b, x) and Enum.member?(c, x)
    end)
    |> Enum.uniq()
  end)
  |> Enum.map(fn [a] ->
    Letter.value(a)
  end)
  |> Enum.sum()

IO.puts("Part 2: #{groups}")
