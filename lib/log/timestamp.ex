defmodule Log.Timestamp do
  def parse({date, {hour, minute, second, micro}}) do
    timestamp = {date, {hour, minute, second}}
    micro_with_precision = {micro * 1000, 3}

    case NaiveDateTime.from_erl(timestamp, micro_with_precision) do
      {:ok, date} -> date
      {:error, _} = err -> err
    end
  end

  def parse!(timestamp) do
    NaiveDateTime.from_erl!(timestamp)
  end
end
