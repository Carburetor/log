defmodule Log.Casing do
  @moduledoc """
  Provides function to change casing of strings, used in `Log.Args`
  """
  def to_pascal(text) when is_binary(text) do
    text
    |> String.split("_")
    |> Enum.reject(fn str -> String.trim(str) == "" end)
    |> Enum.map(&to_title/1)
    |> Enum.join()
  end

  def to_title(<<char::utf8, rest::binary>>) do
    String.upcase(<<char::utf8>>) <> String.downcase(rest)
  end
end
