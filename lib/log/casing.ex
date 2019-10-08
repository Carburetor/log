defmodule Log.Casing do
  @moduledoc """
  Provides function to change casing of strings, used in `Log.Args`
  """
  def to_pascal(text) do
    Recase.to_pascal(text)
  end
end
