defmodule Log.Tag.Always do
  @moduledoc """
  Identifier for special tag `:*` which makes the message always included in
  the output
  """

  defstruct []
  @type t :: %__MODULE__{}
end
