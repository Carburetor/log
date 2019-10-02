defmodule Log.Tag do
  @type t :: atom()

  @spec parse(tag :: String.t()) :: t() | {:error, String.t()}
  def parse(tag)
  def parse("-" <> _ = text), do: {:error, "Tag \"#{text}\" begins with _"}
  def parse(text), do: String.to_atom(text)

  @spec parse!(tag :: String.t()) :: t() | no_return()
  def parse!(tag) do
    case parse(tag) do
      {:error, msg} -> raise ArgumentError, msg
      result -> result
    end
  end
end
