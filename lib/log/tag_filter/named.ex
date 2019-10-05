defmodule Log.TagFilter.Named do
  defstruct name: nil

  @type t :: %__MODULE__{name: Log.Level.t()}
end
