defmodule Log.IO.Sync do
  @behaviour Log.IO

  @impl true
  def write(message)

  def write(%Log.Message{skip?: true} = message), do: IO.inspect(message, label: "skip")
  def write(%Log.Message{output_level: :none} = message), do: IO.inspect(message, label: "none")

  def write(%Log.Message{skip?: false} = message) do
    message_text =
      try do
        :unicode.characters_to_binary(message.text)
      rescue
        ArgumentError ->
          "Invalid log message: #{inspect(message)}"
      end

    message_text = IO.ANSI.format(message_text)
    IO.puts(message.output_device, message_text)
    IO.inspect(message, label: "write")
    message
  end
end
