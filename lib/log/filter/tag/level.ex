defmodule Log.Filter.Tag.Level do
  @moduledoc """
  Provides functions to test if filter level is greater than a certain level.

  When filter level is greater than the given level, tag filter must be
  executed.
  When filter level is equal or below the given level, the message is always
  displayed
  """

  @spec below_or_equal_to?(
          filter :: Log.Filter.Tag.t(),
          level :: Log.Level.t()
        ) ::
          boolean()
  def below_or_equal_to?(%Log.Filter.Tag{} = filter, level) do
    case Log.Level.compare(filter.level, level) do
      :gt -> false
      _ -> true
    end
  end

  @spec above?(
          filter :: Log.Filter.Tag.t(),
          level :: Log.Level.t()
        ) ::
          boolean()
  def above?(%Log.Filter.Tag{} = filter, level) do
    !below_or_equal_to?(filter, level)
  end
end
