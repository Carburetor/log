defmodule Log.Filter do
  def by_level(%Log.Message{} = message) do
    %{output_level: output_level, level: level} = message

    case Log.LevelFilter.match?(output_level, level) do
      true -> message
      false -> Log.Message.skip(message)
    end
  end

  def by_tag_filters(%Log.Message{skip?: true} = message), do: message

  def by_tag_filters(%Log.Message{} = message) do
    case Log.TagFilters.match?(message.output_tags, message.tags) do
      true -> message
      false -> Log.Message.skip(message)
    end
  end
end
