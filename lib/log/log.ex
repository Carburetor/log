defmodule Log do
  use Log.API

  defmacro __using__(opts \\ []) do
    quote do
      use Log.API, unquote(opts)
    end
  end
end
