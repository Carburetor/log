defmodule Log.Filter do
  @moduledoc """
  Provides functions to mark the message as skippable from the log writer
  """

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

  def by_namespaces(%Log.Message{skip?: true} = message), do: message

  def by_namespaces(%Log.Message{config: config} = message) do
    namespaces = config.exclude_namespaces

    case Enum.any?(namespaces, &Log.Namespace.prefix?(message.module, &1)) do
      true ->
        Log.Message.skip(message, "Namespace excluded")

      false ->
        message
    end
  end
end
