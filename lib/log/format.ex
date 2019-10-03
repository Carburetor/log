defmodule Log.Format do
  @spec message(message :: Log.Message.t()) :: String.t()
  def message(%Log.Message{} = message) do
    timestamp = timestamp(message.timestamp, message.utc?)
    module = module(message.module)
    level = level(message.level)
    text = text(message.text)

    output =
      case module do
        "" -> "[#{timestamp}] #{level}: #{text}"
        _ -> "[#{timestamp}] #{module} #{level}: #{text}"
      end

    color(message.config, message.level, output)
  end

  @spec timestamp(date :: NaiveDateTime.t(), utc? :: boolean()) :: String.t()
  def timestamp(date, utc?)
  def timestamp(date, true), do: "#{timestamp(date, false)}Z"
  def timestamp(date, false), do: NaiveDateTime.to_iso8601(date, :extended)

  @spec module(module :: module() | String.t()) :: String.t()
  def module(module) do
    module
    |> to_string()
    |> String.replace_leading("Elixir.", "")
  end

  @spec level(level :: Log.Level.t()) :: String.t()
  def level(level) do
    level
    |> to_string()
    |> String.upcase()
  end

  @spec text(text :: String.t()) :: String.t()
  def text(text) do
    :unicode.characters_to_binary(text)
  rescue
    ArgumentError ->
      text
      |> Logger.Formatter.prune()
      |> :unicode.characters_to_binary()
  end

  @spec color(Log.Config.t(), Log.Level.t(), String.t()) :: String.t()
  def color(config, level, text) do
    colors = Log.Config.get_color(config, level)
    output = [IO.ANSI.reset(), colors, text, IO.ANSI.reset()]
    output = IO.ANSI.format(output)

    to_string(output)
  end
end
