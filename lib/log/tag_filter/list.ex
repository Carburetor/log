defmodule Log.TagFilter.List do
  @moduledoc """
  Provides functions to parse `LOG_TAGS` into a list of `Log.TagFilter.t()`
  """

  alias Log.TagFilter
  alias Log.TagFilter.Condition

  import Kernel, except: [match?: 2]

  @type t :: [TagFilter.t()]

  @spec parse(filters :: String.t() | [String.t()]) ::
          t() | {:error, String.t()}
  def parse(filters)
  def parse([]), do: []

  def parse(filters) when is_binary(filters) do
    filters
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> parse()
  end

  def parse(filters) when is_list(filters) do
    Enum.reduce(filters, [], fn text, parsed_filters ->
      with parsed_filters when is_list(parsed_filters) <- parsed_filters,
           filter when not is_tuple(filter) <- TagFilter.parse(text) do
        [filter | parsed_filters]
      else
        {:error, _} = error -> error
      end
    end)
  end

  @spec parse!(filters :: String.t() | [String.t()]) :: t() | no_return()
  def parse!(filters) do
    case parse(filters) do
      {:error, msg} -> raise ArgumentError, msg
      result -> result
    end
  end

  @spec match?(filters :: t(), tag :: Tag.t() | [Tag.t()]) :: boolean()
  def match?(filters, tag_or_tags)
  def match?([], []), do: false
  def match?([], [_ | _]), do: true

  def match?(filters, tag) when is_list(filters) and not is_list(tag) do
    match?(filters, [tag])
  end

  def match?(filters, tags) when is_list(filters) and is_list(tags) do
    Condition.match?(filters, &TagFilter.match?(&1, tags))
  end
end
