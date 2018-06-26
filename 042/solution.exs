# Calculate triangles on demand. Do no recompute triangles either,
# The map has the {key: value} as {triangle: n}
defmodule StoredTriangles do
    defstruct map: %{}, top: 0, largest: 0

    def to_largest(n, store \\ %StoredTriangles{}) do
        Enum.reduce_while(store.top..n-1, store, fn _, acc ->
            if acc.largest > n, do: {:halt, acc}, else: {:cont, next(acc)}
        end)
    end

    def to(n, store \\ %StoredTriangles{}) do 
        Enum.reduce(store.top..n-1, store, fn _, acc ->
            next(acc)
        end)
    end

    def next(store \\ %StoredTriangles{}) do
        n = store.top + 1
        triangle = compute_triangle(n)
        %StoredTriangles{map: Map.put(store.map, triangle, n), top: n, largest: triangle}
    end

    def compute_triangle(n), do: div(n*(n + 1), 2)
end

defmodule TriangleTest do
    # Get the stream from the file
    def file_word_stream() do
        File.stream!("words.txt", [], 1)
    end

    # Reduce the stream to the answer.
    # Returns {state, answer}
    def solve_stream(stream) do
        stream 
        |> sum_stream
        |> Enum.reduce({%StoredTriangles{}, 0}, fn v, acc ->
            {state, count} = acc
            state = StoredTriangles.to_largest(v+1, state)

            if state.map[v] != nil, do: {state, count + 1}, else: {state, count}
        end)
    end

    # Using chunks to read words into letter sum chunks
    #   This makes it easier to parse the stream, as it is just the word sums
    def chunk_fun(i, acc) do
        [v | _ ] = to_charlist(i)
        if v == ?, do
            {:cont, acc, 0}
        else
            if v == ?", do: {:cont, acc}, else: {:cont, v + acc - ?A + 1}
        end
    end

    def after_fun(acc) do
        case acc do
            0 -> {:cont, 0}
            acc -> {:cont, acc, 0}
        end
    end

    def sum_stream(stream) do
        Stream.chunk_while(stream, 0, &chunk_fun/2, &after_fun/1)
    end
end

# State is unused
{_, acc} = TriangleTest.file_word_stream |> TriangleTest.solve_stream
IO.puts inspect(acc) # 162