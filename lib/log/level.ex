defmodule Log.Level do
  @default [:debug, :info, :warn, :error]
  @levels (case Application.get_env(:log, :levels, @default) do
             [] ->
               raise ArgumentError, "At least one level is required for Log"

             levels ->
               cond do
                 Enum.any?(levels, fn level -> !is_atom(level) end) ->
                   raise ArgumentError, "Levels must all be atoms"

                 Enum.any?(
                   levels,
                   fn level ->
                     to_string(level) |> String.starts_with?("_")
                   end
                 ) ->
                   raise ArgumentError, "Levels must not start with underscore"

                 :none in levels ->
                   raise ArgumentError, ":none is a reserved level"

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

  @type t :: atom() | :none
  @type weight :: non_neg_integer() | :none

  @spec levels() :: [t()]
  def levels, do: @levels

  @spec parse(level :: String.t()) :: t() | {:error, String.t()}
  def parse(level)
  def parse("_min"), do: min()
  def parse("_max"), do: max()
  def parse("_none"), do: :none

  for level <- Enum.map(@levels, &Kernel.to_string/1) do
    def parse(unquote(level)), do: unquote(level)
  end

  def parse(level), do: {:error, "Level #{level} doesn't exist"}

  @spec parse!(level :: String.t()) :: t() | no_return()
  def parse!(level) do
    case parse(level) do
      {:error, msg} -> raise ArgumentError, msg
      result -> result
    end
  end

  @spec get_weight(level :: t()) :: weight()
  def get_weight(level) do
    case level do
      :none -> :none
      _ -> Map.get(@level_weights, level)
    end
  end

  @spec min() :: t()
  def min, do: List.first(@levels)

  @spec max() :: t()
  def max, do: List.last(@levels)

  @spec compare(left :: t(), right :: t()) :: :eq | :gt | :lt
  def compare(left, right) do
    case {get_weight(left), get_weight(right)} do
      {:none, :none} -> :lt
      {:none, _} -> :lt
      {_, :none} -> :gt
      {lweight, rweight} when lweight < rweight -> :lt
      {lweight, rweight} when lweight == rweight -> :eq
      {lweight, rweight} when lweight > rweight -> :gt
    end
  end

  @spec none?(level :: t()) :: boolean()
  def none?(level)
  def none?(:none), do: true
  def none?(_), do: false
end
