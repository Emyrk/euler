defmodule Node do
  defstruct left: nil, right: nil
  defstruct files: []
  defstruct idx: nil
end

defmodule File do
  defstruct name: nil, size: nil
end

defmodule Tree do
  defstruct nodes: %{
              0 => %Node{idx: 0}
            }

  defstruct pointer: 0

  def left(tree, idx) do
    Enum.at(tree, idx * 2 + 1, nil)
  end

  def right(tree, idx) do
    Enum.at(tree, idx * 2 + 2, nil)
  end

  def insert(tree, node, idx) do
    Map.put(tree, idx, node)
  end

  def fetch(tree, idx) do
    Map.get(tree, idx, nil)
  end

  def cmd(tree, cmd) do
    [bin | arg] = cmd

    case bin do
      "cd" ->
        nil

      "ls" ->
        nil
    end
  end
end

File.stream!("easy.txt")
|> Stream.map(&String.trim(&1, "\n"))
|> Enum.reduce(%{}, fn line, acc ->
  split = String.split(line, " ")
  [hd | tl] = split

  cond do
    hd == "$" ->
      # Command
      nil

    hd == "dir" ->
      # Dir
      nil

    true ->
      # File
      nil
  end

  IO.inspect(split)
end)
