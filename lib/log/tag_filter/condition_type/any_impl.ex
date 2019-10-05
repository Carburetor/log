defimpl Log.TagFilter.ConditionType, for: Any do
  @spec get(tag_filter :: Log.TagFilter.t()) :: Log.TagFilter.Condition.t()
  def get(_), do: :or
end
