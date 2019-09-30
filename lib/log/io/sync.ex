defmodule Log.IO.Sync do
  @behaviour Log.IO

  @impl true
  def write(device, output) do
    msg =
      try do
        :unicode.characters_to_binary(output)
      rescue
        ArgumentError ->
          "Invalid log message: #{inspect(output)}"
      end

    msg = IO.ANSI.format(msg)
    IO.puts(device, msg)
  end
end
