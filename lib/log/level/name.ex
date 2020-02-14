defmodule Log.Level.Name do
  @moduledoc """
  Provides functions to parse level strings
  """

  alias Log.Level

  @spec parse(level :: String.t()) :: {:ok, Level.t()} | {:error, String.t()}
  def parse(level)
  def parse("_min"), do: {:ok, Level.min()}
  def parse("_max"), do: {:ok, Level.max()}

  for {name, lv} <- Enum.map(Level.all(), fn lv -> {to_string(lv), lv} end) do
    def parse(unquote(name)), do: {:ok, unquote(lv)}
  end

  def parse(level), do: {:error, "Level #{inspect(level)} doesn't exist"}

  @spec parse!(level :: String.t()) :: Level.t() | no_return()
  def parse!(level) do
    case parse(level) do
      {:error, msg} -> raise ArgumentError, msg
      {:ok, result} -> result
    end
  end
end
