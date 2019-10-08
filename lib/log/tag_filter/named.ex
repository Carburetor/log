defmodule Log.TagFilter.Named do
  @moduledoc """
  Datastructure representing a tag with no prefix: `tag1`.
  A tag with no prefix will be matched with an `or` condition (inclusive):

  `[:tag1, :tag2]` matches any message with only tag1, with only tag2 and
  with both tag1 and tag2
  """

  defstruct name: nil

  @type t :: %__MODULE__{name: Log.Level.t()}
end
