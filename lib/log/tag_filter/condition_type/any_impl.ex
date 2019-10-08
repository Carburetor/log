defimpl Log.TagFilter.ConditionType, for: Any do
  @doc """
  Default implementation for tag filters.
  By default, all filters are checked using an `or` condition
  """
  @spec get(tag_filter :: Log.TagFilter.t()) :: Log.TagFilter.Condition.t()
  def get(_), do: :or
end
