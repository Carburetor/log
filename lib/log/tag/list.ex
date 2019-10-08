defmodule Log.Tag.List do
  @moduledoc """
  Provides functions to parse a list of atoms into a list of tags
  """

  alias Log.Tag

  @type t :: [Tag.t()]

  @spec parse(tags :: [atom()]) :: t() | {:error, String.t()}
  def parse(tags)
  def parse([]), do: []

  def parse(tags) when is_list(tags) do
    Enum.reduce(tags, [], fn text, parsed_tags ->
      with parsed_tags when is_list(parsed_tags) <- parsed_tags,
           tag when not is_tuple(tag) <- Tag.parse(text) do
        [tag | parsed_tags]
      else
        {:error, _} = error -> error
      end
    end)
  end

  @spec parse!(tags :: [atom()]) :: t() | no_return()
  def parse!(tags) do
    case parse(tags) do
      {:error, msg} -> raise ArgumentError, msg
      result -> result
    end
  end
end
