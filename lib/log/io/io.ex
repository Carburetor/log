defmodule Log.IO do
  @callback write(message :: Log.Message.t()) :: Log.Message.t()
end
