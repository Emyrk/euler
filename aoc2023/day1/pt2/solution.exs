# Mapping of words to numbers
mapping = [
  # {"zero", "0"},
  # {"one", "1"},
  # {"two", "2"},
  # {"three", "3"},
  {"four", "4"},
  {"five", "5"},
  {"six", "6"},
  {"seven", "7"},
  {"eight", "8"},
  {"nine", "9"}
]

defmodule Util do
  @numeric_words_tree %{
    # ?z => %{
    #   ?e => %{
    #     ?r => %{
    #       ?o => ?0
    #     }
    #   }
    # },
    ?o => %{
      ?n => %{
        ?e => ?1
      }
    },
    ?t => %{
      ?w => %{
        ?o => ?2
      },
      ?h => %{
        ?r => %{
          ?e => %{
            ?e => ?3
          }
        }
      }
    },
    ?f => %{
      ?o => %{
        ?u => %{
          ?r => ?4
        }
      },
      ?i => %{
        ?v => %{
          ?e => ?5
        }
      }
    },
    ?s => %{
      ?i => %{
        ?x => ?6
      },
      ?e => %{
        ?v => %{
          ?e => %{
            ?n => ?7
          }
        }
      }
    },
    ?e => %{
      ?i => %{
        ?g => %{
          ?h => %{
            ?t => ?8
          }
        }
      }
    },
    ?n => %{
      ?i => %{
        ?n => %{
          ?e => ?9
        }
      }
    }
  }

  # parse_numbers needs to read the word from left to right, replacing the numeric
  # words with their numeric values.
  #
  # The hard part is things like "eightwothree" should be 83, not 823.
  def parse_numbers(line) do
    parsed =
      line
      |> String.downcase()
      |> String.to_charlist()
      |> Enum.reduce(%{chars: [], trees: []}, fn c, acc ->
        %{chars: chars, trees: trees} = acc

        if c in ?0..?9 do
          # This kills any tree strings in progress.
          # IO.puts("Easy escape: #{inspect(List.to_string([c]))}")
          %{chars: chars ++ [c], trees: []}
        else
          # IO.puts("Char: #{inspect(List.to_string([c]))}")
          # Advance each tree by one character
          # IO.puts("Trees: #{inspect(trees)}")

          trees =
            trees
            |> Enum.map(fn t ->
              # IO.puts("Tree: #{inspect(t)}")
              next = Map.get(t, c)

              cond do
                # End of the line
                nil ->
                  nil

                # Continue!
                true ->
                  # IO.puts("Next_map: #{inspect(next)} with #{inspect(List.to_string([c]))}")
                  next
              end
            end)
            # Remove nils
            |> Enum.filter(&(&1 != nil))

          # IO.puts("Trees After: #{inspect(trees)}")

          # Did we find a number? Can we stop?!
          num =
            Enum.find(trees, fn t ->
              not is_map(t)
            end)

          # Possible new word start
          root = @numeric_words_tree[c]
          # IO.puts("Root: #{inspect(root)}")

          cond do
            num != nil ->
              # found a number!
              # IO.puts("Num: #{inspect(List.to_string([num]))}")
              %{chars: chars ++ [num], trees: []}

            root != nil ->
              %{chars: chars, trees: trees ++ [root]}

            root == nil ->
              %{chars: chars, trees: trees}
          end

          # END
        end
      end)

    IO.puts("Parsed: #{inspect(Map.get(parsed, :chars))} from \"#{line}\"")

    # return the original line for now
    Map.get(parsed, :chars)
  end
end

reduced =
  File.stream!("input.txt")
  |> Enum.to_list()
  |> Enum.map(&String.trim(&1, "\n"))
  |> Enum.map(fn line ->
    line
    |> Util.parse_numbers()
    # |> String.to_charlist()
    |> Enum.reduce([], fn i, acc ->
      if i in ?0..?9 do
        if(length(acc) > 0) do
          [hd | _] = acc
          [hd, i]
        else
          [i, i]
        end
      else
        acc
      end
    end)
  end)
  |> Enum.map(fn tuples ->
    tuples
    |> List.to_string()
    |> String.to_integer()
  end)
  |> Enum.sum()

IO.puts("Answer: #{reduced |> inspect()}")
