defmodule Log.Level do
  alias Log.Config

  def allowed?(%Config{} = config, output_level) do
    case exist?(config, output_level) do
      false ->
        false

      true ->
        log_level = Config.get_level(config)
        log_level_weight = get_weight(config, log_level)
        level_weight = get_weight(config, output_level)

        log_level_weight <= level_weight
    end
  end

  def exist?(%Config{level_weights: level_weights}, output_level) do
    Map.has_key?(level_weights, output_level)
  end

  def get_weight(%Config{level_weights: level_weights}, output_level) do
    case Map.get(level_weights, output_level) do
      nil -> raise ArgumentError, message: "Output level is invalid: #{output_level}"
      weight -> weight
    end
  end
end
