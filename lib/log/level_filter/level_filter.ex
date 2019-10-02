defmodule Log.LevelFilter do
  alias Log.LevelFilter.None
  alias Log.Level

  @type t :: Level.t() | None.t()

  @spec parse(level :: String.t()) :: t() | {:error, String.t()}
  def parse(level)
  def parse("_min"), do: Level.min()
  def parse("_max"), do: Level.max()
  def parse("_none"), do: %None{}

  for {name, lv} <- Enum.map(Level.all(), fn lv -> {to_string(lv), lv} end) do
    def parse(unquote(name)), do: unquote(lv)
  end

  def parse(level), do: {:error, "Level #{inspect(level)} doesn't exist"}

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
