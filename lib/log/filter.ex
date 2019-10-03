defmodule Log.Filter do
  def by_level(%Log.Message{} = message) do
    %{output_level: output_level, level: level} = message

    case Log.LevelFilter.match?(output_level, level) do
      true ->
        message

      false ->
        Log.Message.skip(
          message,
          "Level filter #{inspect(output_level)} did not match"
        )
    end
  end

  def by_tag_filters(%Log.Message{skip?: true} = message), do: message

  def by_tag_filters(%Log.Message{} = message) do
    case Log.TagFilter.List.match?(message.output_tags, message.tags) do
      true ->
        message

      false ->
        Log.Message.skip(
          message,
          "Tag filter #{inspect(message.output_tags)} did not match"
        )
    end
  end
end
