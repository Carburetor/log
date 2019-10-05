defprotocol Log.TagFilter.ConditionType do
  @fallback_to_any true
  @spec get(tag_filter :: Log.TagFilter.t()) :: Log.TagFilter.Condition.t()
  def get(tag_filter)
end
