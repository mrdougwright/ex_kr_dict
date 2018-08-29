defmodule KrDict.Util.Dict do
  def load(file_path) do
    File.stream!(file_path)
    |> CSV.decode(separator: ?\t)
    |> Stream.each(fn row ->
      IO.inspect(row)
    end)
    |> Enum.take(1)
  end
end
