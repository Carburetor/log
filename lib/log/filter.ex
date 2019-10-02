defmodule Log.Filter do
  def by_level(%Log.Message{} = message) do
    %{output_level: output_level, level: level} = message

    case Log.Level.compare(level, output_level) do
      :lt -> Log.Message.skip(message)
      _ -> message
    end
  end
end
