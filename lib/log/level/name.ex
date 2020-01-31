defmodule Log.Level.Name do
  @moduledoc """
  Provides functions to parse level strings
  """

  alias Log.Level

  @spec parse(level :: String.t()) :: Level.t() | {:error, String.t()}
  def parse(level)
  def parse("_min"), do: Level.min()
  def parse("_max"), do: Level.max()

  for {name, lv} <- Enum.map(Level.all(), fn lv -> {to_string(lv), lv} end) do
    def parse(unquote(name)), do: unquote(lv)
  end

  def parse(level), do: {:error, "Level #{inspect(level)} doesn't exist"}

  @spec parse!(level :: String.t()) :: Level.t() | no_return()
  def parse!(level) do
    case parse(level) do
      {:error, msg} -> raise ArgumentError, msg
      result -> result
    end
  end
end
