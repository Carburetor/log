defmodule Log.TagFilter.Condition do
  @type t :: :and | :or

  @spec get_type(tag_filter :: Log.TagFilter.t()) :: t()
  def get_type(tag_filter) do
    Log.TagFilter.ConditionType.get(tag_filter)
  end

  @spec match?(
          tag_filters :: Log.TagFilter.List.t(),
          matcher :: (Log.TagFilter.t() -> boolean())
        ) :: boolean()
  def match?(tag_filters, matcher) do
    grouped = Enum.group_by(tag_filters, &get_type/1)
    and_filters = Map.get(grouped, :and, [])
    or_filters = Map.get(grouped, :or, [])

    case {and_filters, and_match?(and_filters, matcher)} do
      {[], _} -> or_match?(or_filters, matcher)
      {_, true} -> true
      {_, false} -> false
    end
  end

  def and_match?([], _matcher), do: true
  def and_match?(filters, matcher), do: Enum.all?(filters, matcher)
  def or_match?([], _matcher), do: true
  def or_match?(filters, matcher), do: Enum.any?(filters, matcher)
end
