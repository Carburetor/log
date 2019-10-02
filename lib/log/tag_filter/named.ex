defmodule Log.TagFilter.Named do
  defstruct name: nil, exclude?: false

  @type t :: %__MODULE__{name: Log.Level.t(), exclude?: boolean()}
end
