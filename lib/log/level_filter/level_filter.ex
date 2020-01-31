defmodule Log.LevelFilter do
  @moduledoc """
  Provides functions to parse `LOG_LEVEL` into filtering
  """

  alias Log.LevelFilter.None
  alias Log.Level

  @type t :: Level.t() | None.t()

  @spec parse(level :: String.t()) :: t() | {:error, String.t()}
  def parse(level)
  def parse("_none"), do: %None{}
  def parse(level), do: Level.Name.parse(level)

  @spec parse!(level :: String.t()) :: t() | no_return()
  def parse!(level) do
    case parse(level) do
      {:error, msg} -> raise ArgumentError, msg
      result -> result
    end
  end

  @spec match?(filter :: t(), level :: Level.t()) :: boolean()
  def match?(filter, level)
  def match?(%None{}, _level), do: false

  def match?(filter, level) do
    filter_weight = Level.get_weight(filter)
    level_weight = Level.get_weight(level)
    filter_weight <= level_weight
  end
end
