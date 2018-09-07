defmodule TrieTest do
  use ExUnit.Case
  require IEx

  def barf(%TrieNode{children: children}, result \\ []) do
    children
    |> Enum.reduce(result, fn {val, next}, acc ->
      acc ++ barf(next, [val])
    end)
    |> Enum.map(&List.to_string([&1]))
  end

  test "insert/2 can insert a word" do
    trie = Trie.insert("공기")
    trie = Trie.insert("ㄱㅗㅇㄱㅣ")
    assert barf(trie) == ["ㄱ", "ㅗ", "ㅇ", "ㄱ", "ㅣ"]
  end

  test "insert/2 can insert an existing word" do
    trie =
      Trie.insert("ㄱㅗㅇㄱㅣ")
      |> Trie.insert("ㄱㅗㅇㄱㅣ")

    assert barf(trie) == ["ㄱ", "ㅗ", "ㅇ", "ㄱ", "ㅣ"]
  end

  test "insert/2 handles empty string inserts" do
    trie = Trie.insert("")
    assert barf(trie) == []
  end

  test "insert/2 can insert another word with same initial" do
    trie =
      Trie.insert("ㄱㅗㅇㄱㅣ")
      |> Trie.insert("ㄱㅗㅇㄱㅣㅂㅏㅂ")

    assert barf(trie) == ["ㄱ", "ㅗ", "ㅇ", "ㄱ", "ㅣ", "ㅂ", "ㅏ", "ㅂ"]
  end

  test "insert/2 can insert another word with different initial" do
    trie =
      Trie.insert("ㄱㅗㅇㄱㅣ")
      |> Trie.insert("ㄱㅗㅏㅇㅎㅗㅏㅁㅜㄴ")

    assert barf(trie) == ["ㄱ", "ㅗ", "ㅇ", "ㄱ", "ㅣ", "ㅏ", "ㅇ", "ㅎ", "ㅗ", "ㅏ", "ㅁ", "ㅜ", "ㄴ"]
  end

  test "find/2 can find inserted word" do
    result =
      Trie.insert("ㄱㅗㅇㄱㅣ")
      |> Trie.insert("ㄱㅗㅏㅇㅎㅗㅏㅁㅜㄴ")
      |> Trie.find("ㄱㅗㅇㄱㅣ")

    assert result == ["ㄱ", "ㅗ", "ㅇ", "ㄱ", "ㅣ"]
  end

  test "find/2 will not find anything input does not match inserted initial" do
    found =
      Trie.insert("ㄱㅗㅇㄱㅣ")
      |> Trie.insert("ㄱㅗㅏㅇㅎㅗㅏㅁㅜㄴ")
      |> Trie.find("ㄱㅗㅇㅑㅇㅇㅣ")

    assert found == nil
  end

  test " find/2 will not find anything if input matches non-initial syllable" do
    found =
      Trie.insert("ㄱㅗㅇㄱㅣ")
      |> Trie.insert("ㄱㅗㅏㅇㅎㅗㅏㅁㅜㄴ")
      |> Trie.find("ㄱㅣ")

    assert found == nil
  end

  test "find/2 will not match partial non-words" do
    found =
      Trie.insert("ㄱㅗㅏㅇㅎㅗㅏㅁㅜㄴ")
      |> Trie.find("ㄱㅗㅏㅇ")

    assert found == nil
  end

  @tag :sad
  test "prefix/2 deals with empty string" do
    found =
      Trie.insert("ㄱㅗㅇㄱㅣ")
      |> Trie.insert("ㄱㅗㅇㄱㅣㅂㅏㅂ")
      |> Trie.insert("ㄱㅗㅇㅎㅏㅇㅂㅓㅅㅡ")
      |> Trie.prefix("")

    assert found == {0, []}
  end

  @tag :sad
  test "prefix/2 find any words that share a prefix" do
    found =
      Trie.insert("ㄱㅗㅇ")
      |> Trie.prefix("ㄱㅗㅇ")

    assert found == {1,[["ㄱ", "ㅗ", "ㅇ"]]}
  end

  @tag :bad
  test "prefix/2 will return the prefix as well if it is a word", %{trie: trie} do
    Trie.insert(trie, "공기")
    Trie.insert(trie, "공기밥")
    Trie.insert(trie, "공항버스")

    assert {:ok, ["공기", "공기밥"]} = Trie.prefix(trie, "공기")
  end

  @tag :bad
  test "prefix/2 will not return the prefix as well if it is not a word", %{trie: trie} do
    Trie.insert(trie, "공기")
    Trie.insert(trie, "공기밥")
    Trie.insert(trie, "공항버스")

    assert {:ok, ["공항버스"]} = Trie.prefix(trie, "공항버")
  end
end
