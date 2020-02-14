defmodule Log.Level do
  @moduledoc """
  Provides functions to configure and order different levels
  """

  @default [:trace, :debug, :info, :warn, :error, :fatal]
  @levels (case Application.get_env(:log, :levels, @default) do
             [] ->
               raise ArgumentError, "At least one level is required for Log"

             levels ->
               cond do
                 Enum.any?(levels, fn level -> !is_atom(level) end) ->
                   raise ArgumentError, "Levels must all be atoms"

                 !Enum.all?(@default, fn level -> level in levels end) ->
                   raise(
                     ArgumentError,
                     "Levels :debug, :info, :warn and :error required"
                   )

                 true ->
                   levels
               end
           end)
  @level_weights Enum.with_index(@levels) |> Map.new()
  @level_name_max_length @levels
                         |> Enum.map(&Kernel.to_string/1)
                         |> Enum.map(&String.length/1)
                         |> Enum.sort()
                         |> List.last()

  @type t :: atom()
  @type weight :: non_neg_integer()

  @spec name_max_length() :: pos_integer()
  def name_max_length, do: @level_name_max_length

  @spec all() :: [t()]
  def all, do: @levels

  @spec parse(level :: atom()) :: t() | {:error, String.t()}
  def parse(level)

  for level <- @levels do
    def parse(unquote(level)), do: unquote(level)
  end

  def parse(level), do: {:error, "Level #{inspect(level)} doesn't exist"}

  @spec parse!(level :: atom()) :: t() | no_return()
  def parse!(level) do
    case parse(level) do
      {:error, msg} -> raise ArgumentError, msg
      result -> result
    end
  end

  @spec get_weight(level :: t()) :: weight()
  def get_weight(level), do: Map.get(@level_weights, level)

  @spec compare(left :: t(), right :: t()) :: :lt | :eq | :gt
  def compare(left, right) do
    left_weight = get_weight(left)
    right_weight = get_weight(right)

    cond do
      left_weight < right_weight -> :lt
      left_weight == right_weight -> :eq
      left_weight > right_weight -> :gt
    end
  end

  @spec min() :: t()
  def min, do: all() |> List.first()

  @spec max() :: t()
  def max, do: all() |> List.last()
end
