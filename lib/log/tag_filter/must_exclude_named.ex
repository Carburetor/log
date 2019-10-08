defmodule Log.TagFilter.MustExcludeNamed do
  @moduledoc """
  Datastructure representing a tag prefixed with dash: `-tag1`.
  A tag prefixed with dash **must be absent** from the list of tags of the
  message
  """

  defstruct name: nil

  @type t :: %__MODULE__{name: Log.Level.t()}

  defimpl Log.TagFilter.ConditionType do
    @spec get(tag_filter :: Log.TagFilter.t()) :: Log.TagFilter.Condition.t()
    def get(_), do: :and
  end
end
