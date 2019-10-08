defmodule Log.Timestamp do
  @moduledoc """
  Provides functions to convert from a Logger timestamp to a
  `NaiveDateTime.t()`
  """

  def parse({date, {hour, minute, second, micro}}) do
    timestamp = {date, {hour, minute, second}}
    micro_with_precision = {micro * 1000, 3}

    case NaiveDateTime.from_erl(timestamp, micro_with_precision) do
      {:ok, date} -> date
      {:error, _} = err -> err
    end
  end
end
