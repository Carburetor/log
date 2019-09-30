defmodule Log.Config do
  defstruct level_weights: %{
              "debug" => 0,
              "info" => 1,
              "warn" => 2,
              "error" => 3
            },
            levels: ["debug", "info", "warn", "error"],
            colors: %{}

  def build(opts \\ []) do
    opts =
      opts
      |> Keyword.put_new(:levels, [:debug, :info, :warn, :error])
      |> Keyword.put_new(:colors, %{})

    colors = Keyword.get(opts, :colors)
    levels = Keyword.get(opts, :levels)
    levels = Enum.map(levels, &Kernel.to_string/1)

    weights =
      levels
      |> Enum.with_index(0)
      |> Map.new()

    %__MODULE__{levels: levels, level_weights: weights, colors: colors}
  end

  def level_allowed?(%__MODULE__{} = config, output_level) do
    log_level = get_level(config)
    log_level_weight = get_level_weight(config, log_level)
    level_weight = get_level_weight(config, output_level)

    log_level_weight <= level_weight
  end

  def get_color(%__MODULE__{colors: colors}, output_level) do
    case Map.get(colors, output_level, [IO.ANSI.normal()]) do
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

  def get_level_weight(%__MODULE__{} = config, output_level) do
    level_weights = config.level_weights

    case Map.get(level_weights, output_level) do
      nil -> raise ArgumentError, message: "Output level is invalid: #{output_level}"
      weight -> weight
    end
  end
end
