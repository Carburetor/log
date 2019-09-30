defmodule Log.Config do
  defstruct level_weights: %{
              "debug" => 0,
              "info" => 1,
              "warn" => 2,
              "error" => 3
            },
            levels: ["debug", "info", "warn", "error"],
            colors: %{}

  @spec coerce_levels(levels :: [atom()]) :: %{
          levels: [String.t()],
          level_weights: %{optional(String.t()) => non_neg_integer()}
        }
  def coerce_levels(levels) do
    text_levels = Enum.map(levels, &Kernel.to_string/1)

    weights =
      text_levels
      |> Enum.with_index(0)
      |> Map.new()

    %{levels: text_levels, level_weights: weights}
  end

  @spec coerce_colors(colors :: %{optional(atom()) => IO.ANSI.ansidata()}) :: %{
          optional(String.t()) => IO.ANSI.ansidata()
        }
  def coerce_colors(%{} = colors) do
    colors
    |> Enum.map(fn {name, color} -> {to_string(name), color} end)
    |> Map.new()
  end

  def build(opts \\ []) do
    opts =
      opts
      |> Keyword.put_new(:levels, [:debug, :info, :warn, :error])
      |> Keyword.put_new(:colors, %{})

    colors = coerce_colors(Keyword.get(opts, :colors))
    levels = coerce_levels(Keyword.get(opts, :levels))

    %__MODULE__{colors: colors}
    |> Map.merge(levels)
  end

  def get_color(%__MODULE__{colors: colors}, output_level) do
    case Map.get(colors, to_string(output_level), [IO.ANSI.normal()]) do
      list when is_list(list) -> list
      not_list -> [not_list]
    end
  end

  def get_device do
    device = System.get_env("CONSOLE_DEVICE", "stdout")
    Log.Device.get(device)
  end

  def get_level(%__MODULE__{levels: []}) do
    raise ArgumentError, message: "No log levels provided"
  end

  def get_level(%__MODULE__{level_weights: level_weights, levels: levels}) do
    with log_level <- System.get_env("LOG_LEVEL"),
         log_level when log_level != :no_env_var <- log_level,
         level <- Map.get(level_weights, log_level, :not_exist),
         level when level != :not_exist <- level do
      log_level
    else
      nil -> List.first(levels)
      :not_exist -> raise ArgumentError, message: "LOG_LEVEL is invalid"
    end
  end
end
