defmodule Log.IO do
  @moduledoc """
  Behaviour for writing a `Log.Message.t()` to IO
  """

  @callback write(message :: Log.Message.t()) :: Log.Message.t()
end
