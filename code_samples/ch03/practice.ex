defmodule Practice do
  defp get_lines!(path) do
    path
    |> File.stream!()
    |> Stream.map(&String.trim_trailing(&1, "\n"))
  end

  defp word_count(text) do
    text
    |> String.split()
    |> length()
  end

  def line_lengths!(path) do
    path
    |> get_lines!()
    |> Enum.map(&String.length/1)
  end

  def longest_line!(path) do
    path
    |> get_lines!()
    |> Enum.max_by(&String.length/1)
  end

  def longest_line_length!(path) do
    path
    |> line_lengths!()
    |> Enum.max()
  end

  def words_per_line!(path) do
    path
    |> get_lines!()
    |> Stream.with_index()
    |> Enum.map(fn {el, idx} -> {idx, word_count(el)} end)
  end
end
