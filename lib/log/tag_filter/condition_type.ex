defprotocol Log.TagFilter.ConditionType do
  @fallback_to_any true

  @doc """
  Gets if the filter is checked as an `or` condition or as an `and` condition
  """
  @spec get(tag_filter :: Log.TagFilter.t()) :: Log.TagFilter.Condition.t()
  def get(tag_filter)
end
