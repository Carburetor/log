defmodule Log do
  @moduledoc """
  Log frontend for `Logger`
  """

  use Log.API

  defmacro __using__(opts \\ []) do
    quote do
      use Log.API, unquote(opts)
    end
  end
end
