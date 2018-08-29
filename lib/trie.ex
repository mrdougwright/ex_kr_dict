defmodule Trie do
  def insert(to_insert) do
    insert(%TrieNode{}, to_insert)
  end

  def insert(current_node, to_insert) do
    insert(current_node, [], current_node, to_insert)
  end

  def insert(_current_node, path, root, "") do
    root
  end

  def insert(%TrieNode{children: children}, path, root, <<char::utf8>> <> rest) do
    new_path = path ++ [char]
    accessor = [Access.key(:children) | Enum.intersperse(new_path, Access.key(:children))]

    case Map.get(children, char) do
      nil ->
        next_node = %TrieNode{value: char, is_word: String.length(rest) == 0}

        insert(
          next_node,
          path ++ [char],
          put_in(root, accessor, next_node),
          rest
        )

      next_node ->
        insert(next_node, new_path, root, rest)
    end
  end

  def find(%TrieNode{} = trie, query) do
    find(trie, [], query)
  end

  def find(%TrieNode{is_word: true}, found, "") do
    found
    |> Enum.reverse()
    |> Enum.map(&List.to_string([&1]))
  end

  def find(t, _found, "") do
    nil
  end

  def find(%TrieNode{children: children} = current_node, found, <<char::utf8>> <> rest) do
    case Map.get(children, char) do
      nil ->
        nil

      next_node ->
        find(%{next_node | prev: current_node}, [char | found], rest)
    end
  end

  def prefix(%TrieNode{} = trie, query) do
    IO.puts("prefix start 1")
    prefix(trie, [], query)
  end

  # This means we have reached the end of the search string
  def prefix(%TrieNode{value: val, is_word: true, children: children} = current_node, found, "") do
    IO.puts("prefix end 1")
    found = [val | found]
    IO.puts("starting to gather prefixes at word boundry")
    gather_prefixes(current_node, found, [Enum.reverse(found)])
  end

  def prefix(%TrieNode{children: children, value: val} = current_node, found, "") do
    IO.puts("starting to gather prefixes at non-word boundry")
    gather_prefixes(current_node, [val | found], [])
  end

  def prefix(%TrieNode{children: children} = current_node, found, <<char::utf8>> <> rest) do
    IO.puts("prefix start 2")

    case Map.get(children, char) do
      nil -> nil
      next_node -> prefix(%{next_node | prev: current_node}, [char | found], rest)
    end
  end

  defp gather_prefixes(%{children: children, value: val, is_word: true}, current, found)
       when children == %{} do
    [Enum.reverse([val | current]) | found]
  end

  defp gather_prefixes(%{children: children, value: val, is_word: false}, _current, found)
       when children == %{} do
    found
  end

  defp gather_prefixes(%{value: val, children: children}, current, found) do
    children
    |> Enum.flat_map(fn
      {_, %{is_word: false, value: val} = next_node} ->
        gather_prefixes(next_node, current ++ [val], found)

      {_, %{is_word: true, children: next_children, value: val} = next_node} ->
        word = current ++ [val]
        IO.puts("adding the word")
        IO.inspect(word)
        gather_prefixes(next_node, word, [word | found])
    end)
    |> (fn res ->
          IO.puts("Result here")
          IO.inspect(Enum.map(res, &List.to_string(&1)))
          res
        end).()
  end
end
