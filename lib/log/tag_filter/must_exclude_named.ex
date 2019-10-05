defmodule Log.TagFilter.MustExcludeNamed do
  defstruct name: nil

  @type t :: %__MODULE__{name: Log.Level.t()}

  defimpl Log.TagFilter.ConditionType do
    @spec get(tag_filter :: Log.TagFilter.t()) :: Log.TagFilter.Condition.t()
    def get(_), do: :and
  end
end
