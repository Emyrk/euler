# The difference to 18, is that when building the tree, each node
# becomes the sum of it's value, and the greater of it's left or right
# value. So the root is the maximum path.
defmodule Tree do
    defstruct left: nil, right: nil, value: 0 

    def build_tree() do
        collapse_tree(build_tree_list())
    end

    def build_tree_list() do
        File.stream!("tree.txt") 
        |> Enum.reverse 
        |> Enum.map( fn s ->
            String.split(s, " ") |> Enum.map(fn s ->
                { i, _ } = Integer.parse(s)
                %Tree{value: i}
                # i
            end)
        end)
    end

    def collapse_tree(tree) do
        [b | t] = tree
        collapse_tree(b, t)
    end

    def collapse_tree(next_bottom, tree) when tree == [] do
        hd(next_bottom)
    end

    def collapse_tree(next_bottom, tree) do
        [_ | rest] = tree
        next_bottom = collapse_row(next_bottom, hd(tree))
        collapse_tree(next_bottom, rest)
    end

    def collapse_row(_, row_top) when row_top == [] do
        []
    end

    def collapse_row(row_bot, row_top) do
        l_r = row_bot |> Enum.take(2)
        [l | r] = l_r
        r = hd(r)
        [head | rest] = row_top
        head = Map.merge(head, %{left: l, right: r})
        head = Map.put(head, :value, Enum.max([r.value, l.value]) + head.value)

        [_ | bot_rest] = row_bot
        [head] ++ collapse_row(bot_rest, rest)
    end

    def print_tree(root) do
        print_recurse([root])
    end

    def print_tree_row(row) do
        f = hd(row)
        if f != nil do
            {str, next_row} = row |> Enum.reduce({"", [f.left]}, fn e, acc ->
                {str, list} = acc
                str = str <> " " <> inspect(e.value)
                {str, list ++ [e.right]}
            end)
            IO.puts str
            next_row
        else 
            []
        end
    end

    def print_recurse(row) when row == [] do

    end

    def print_recurse(row) do
        new_row = print_tree_row(row)
        print_recurse(new_row)
    end

    # Traversing
    def dfs(root) do
        dfs(0, root)
    end

    def dfs(sum, node) when node == nil do
        sum
    end

    def dfs(sum, node) do
        sum = sum + node.value
        leftsum = sum + dfs(0, node.left)
        rightsum = sum + dfs(0, node.right)
        Enum.max([leftsum, rightsum])
    end
end

# 7273
t = Tree.build_tree()
IO.puts(t.value)
