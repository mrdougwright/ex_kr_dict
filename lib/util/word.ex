defmodule KrDict.Util.Word do
  alias KrDict.Util.Hangul
  import KrDict.Util.Hangul, only: [valid_onset?: 1, valid_vowel?: 1, valid_coda?: 1]

  defguard valid_two_char_syllable?(onset, vowel) when valid_onset(onset) and valid_vowel(vowel)

  defguard valid_three_char_syllable?(onset, vowel, coda)
           when valid_onset?(onset) and valid_vowel?(vowel) and valid_coda?(coda)

  def from_hangul_array(hangul) do
    from_hangul_array(hangul, "")
  end

  def from_hangul_array([], result) do
    {:ok, result}
  end

  def from_hangul_array([onset, vowel, possible_onset, possible_vowel | rest], result)
      when valid_two_char_syllable?(onset, vowel) and valid_vowel?(possible_vowel) do
    syllable = %Hangul{onset: onset, vowel: vowel} |> Hangul.compose()
    from_hangul_array([possible_onset, possible_vowel | rest], result <> syllable)
  end

  def from_hangul_array([onset, vowel, coda | rest], result)
      when valid_three_char_syllable?(onset, vowel, coda) do
    syllable = %Hangul{onset: onset, vowel: vowel, coda: coda} |> Hangul.compose()
    from_hangul_array(rest, result <> syllable)
  end

  def from_hangul_array([onset, vowel | rest], result)
      when valid_two_char_syllable?(onset, vowel) do
    syllable = %Hangul{onset: onset, vowel: vowel} |> Hangul.compose()
    from_hangul_array(rest, result <> syllable)
  end

  def from_hangul_array(list, _result), do: {:error, "Invalid Hangul #{inspect(list)}"}

  def to_hangul_array(chars) do
    # "공기"
    result =
      chars
      # ["공", "기"]
      |> String.graphemes()
      # [%Hangul{onset:"ㄱ", vowel: "ㅗ", coda: "ㅇ"}...]
      |> Enum.map(&Hangul.decompose/1)
      |> Enum.flat_map(fn
        {:ok, %KrDict.Util.Hangul{onset: onset, vowel: vowel, coda: nil}} ->
          [onset, vowel]

        {:ok, %KrDict.Util.Hangul{onset: onset, vowel: vowel, coda: coda}} ->
          [onset, vowel, coda]

        {:error, message} ->
          [:error]
      end)

    case Enum.find(result, fn char -> char == :error end) do
      nil -> {:ok, result}
      _other -> {:error, "bad hangul"}
    end
  end
end
