defmodule Log.Passthrough do
  @moduledoc """
  Log frontend for `Logger`, message is written and data is returned for usage
  in pipes. The data is not inspected
  """

  use Log

  def options,
    do: [
      :label
    ]

  @impl true
  def bare_log(data, meta)

  def bare_log(data, meta) when is_function(data) do
    force_log(data.(), meta)
  end

  def bare_log(data, meta) do
    force_log(data, meta)
  end

  def force_log(data, meta) do
    opts = Keyword.take(meta, options())

    text = Keyword.get(opts, :label, "")

    meta = Keyword.drop(meta, options())
    Log.API.bare_log(text, meta)
    data
  end
end
