defmodule Log.IO.Sync do
  @behaviour Log.IO

  @impl true
  def write(message)

  def write(%Log.Message{skip?: true} = message), do: message
  def write(%Log.Message{output_level: :none} = message), do: message

  def write(%Log.Message{skip?: false} = message) do
    message_text = Log.Format.message(message)
    IO.puts(message.output_device, message_text)
    message
  end
end
