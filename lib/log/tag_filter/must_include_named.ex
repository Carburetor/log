defmodule Log.TagFilter.MustIncludeNamed do
  @moduledoc """
  Datastructure representing a tag prefixed with plus: `+tag1`.
  A tag prefixed with plus **must always be present** from the list of
  tags of the message
  """

  defstruct name: nil

  @type t :: %__MODULE__{name: Log.Level.t()}

  defimpl Log.TagFilter.ConditionType do
    @spec get(tag_filter :: Log.TagFilter.t()) :: Log.TagFilter.Condition.t()
    def get(_), do: :and
  end
end
