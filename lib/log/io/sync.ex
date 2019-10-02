defmodule Log.IO.Sync do
  @behaviour Log.IO

  @impl true
  def write(message)

  def write(%Log.Message{skip?: true} = message), do: message
  def write(%Log.Message{output_level: :none} = message), do: message

  def write(%Log.Message{skip?: false} = message) do
    message_text =
      try do
        encode(message.text)
      rescue
        ArgumentError ->
          "Invalid log message: #{inspect(message)}"
      end

    message_text = IO.ANSI.format(message_text)
    IO.puts(message.output_device, message_text)
    message
  end

  def encode(text) do
    :unicode.characters_to_binary(text)
  rescue
    ArgumentError ->
      text
      |> Logger.Formatter.prune()
      |> :unicode.characters_to_binary()
  end
end
