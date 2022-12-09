defmodule Chain do
  defstruct Ropes: []

  def new(n) do
    %Chain{Ropes: Enum.map(1..n, fn _ -> %Rope{} end)}
  end

  def simulate(chain, moves) do
    moves
    |> Enum.map(&String.trim(&1, "\n"))
    |> Enum.map(&String.split(&1, " "))
    |> Enum.reduce(chain, fn [direction, num], acc ->
      moves(acc, direction, String.to_integer(num))
    end)
  end

  def moves(chain, direction, n) do
    # IO.puts("Moving #{n} times in direction #{direction}")

    Enum.reduce(1..n, chain, fn _, acc ->
      move(acc, direction)
    end)
  end

  def move(chain, direction) do
    moved =
      chain.Ropes
      |> Enum.with_index()
      |> Enum.reduce(%{ropes: [], head: nil}, fn {rope, index}, acc ->
        case head do
          nil ->
            rope = Rope.move(rope, direction)

            %{
              ropes: acc.ropes ++ [rope],
              head: rope.tail
            }

          _ ->
            rope = Map.put(rope, :head, acc.head)
            rope = Rope.move(rope, direction)

            %{
              ropes: acc.ropes ++ [rope],
              head: rope.head
            }
        end
      end)

    %Chain{ropes: moved.ropes}
  end
end

defmodule Rope do
  defstruct head: {0, 0}, tail: {0, 0}, visited: %{{0, 0} => true}

  def moves(rope, direction, n) do
    # IO.puts("Moving #{n} times in direction #{direction}")

    Enum.reduce(1..n, rope, fn _, acc ->
      move(acc, direction)
    end)
  end

  def move(rope, direction) do
    # Move the head into the direction
    head =
      case direction do
        "U" ->
          {x, y} = rope.head
          {x, y + 1}

        "D" ->
          {x, y} = rope.head
          {x, y - 1}

        "L" ->
          {x, y} = rope.head
          {x - 1, y}

        "R" ->
          {x, y} = rope.head
          {x + 1, y}
      end

    # Move the tail towards the head
    {tx, ty} = rope.tail
    {hx, hy} = head

    dx = hx - tx
    dy = hy - ty

    # IO.puts("Before Head: {#{hx}, #{hy}} Tail: {#{tx}, #{ty}}")
    # IO.puts("dx: #{dx} dy: #{dy}, #{dx > 1 and dy > 1}")

    {newx, newy} =
      cond do
        # Left, Right, Up, Down
        dx > 1 and dy == 0 -> {tx + 1, ty}
        dx < -1 and dy == 0 -> {tx - 1, ty}
        dx == 0 and dy > 1 -> {tx, ty + 1}
        dx == 0 and dy < -1 -> {tx, ty - 1}
        # Diagonals
        # RU
        dx >= 1 and dy > 1 -> {tx + 1, ty + 1}
        dx > 1 and dy >= 1 -> {tx + 1, ty + 1}
        # RD
        dx >= 1 and dy < -1 -> {tx + 1, ty - 1}
        dx > 1 and dy <= -1 -> {tx + 1, ty - 1}
        # LU
        dx <= -1 and dy > 1 -> {tx - 1, ty + 1}
        dx < -1 and dy >= 1 -> {tx - 1, ty + 1}
        # LD
        dx <= -1 and dy < -1 -> {tx - 1, ty - 1}
        dx < -1 and dy <= -1 -> {tx - 1, ty - 1}
        true -> {tx, ty}
      end

    # IO.puts("Head: {#{hx}, #{hy}} Tail: {#{newx}, #{newy}}")

    %Rope{
      head: head,
      tail: {newx, newy},
      visited: Map.put(rope.visited, {newx, newy}, true)
    }
  end

  def simulate(moves) do
    moves
    |> Enum.map(&String.trim(&1, "\n"))
    |> Enum.map(&String.split(&1, " "))
    |> Enum.reduce(%Rope{}, fn [direction, num], acc ->
      moves(acc, direction, String.to_integer(num))
    end)
  end
end

rope = Rope.simulate(File.stream!("input.txt"))
IO.puts("Part 1 Visited: #{Map.size(rope.visited)}")

chain = Chain.new(10)
chain = Chain.simulate(chain, File.stream!("input.txt"))
IO.puts("Part 1 Visited: #{Map.size(Enum.at(chain.ropes, 9).visited)}")

defmodule Expects do
  def testDiagonal() do
    # TR Diagonal
    Expects.test(%Rope{head: {4, 1}, tail: {3, 0}}, "U", 1, {4, 2}, {4, 1})
  end

  def test(rope, direction, n, expectedHead, expectedTail) do
    rope = Rope.moves(rope, direction, n)

    if rope.head != expectedHead do
      {x, y} = expectedHead
      {a, b} = rope.head
      IO.puts("Expected head: {#{x}, #{y}} Got: {#{a}, #{b}}")
    end

    if rope.tail != expectedTail do
      {x, y} = expectedTail
      {a, b} = rope.tail
      IO.puts("Expected tail: {#{x}, #{y}} Got: {#{a}, #{b}}")
    end
  end
end

# IO.puts("TESTS")
# Expects.testDiagonal()
