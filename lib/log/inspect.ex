defmodule Log.Inspect do
  @moduledoc """
  Log frontend for `Logger` focused on performing `inspect` of input data
  """

  use Log, tags: [:inspect]

  def inspect_options,
    do: [
      :structs,
      :binaries,
      :charlists,
      :limit,
      :printable_limit,
      :pretty,
      :width,
      :base,
      :safe,
      :syntax_colors,
      :inspect_fun,
      :custom_options,
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
    inspect_opts = Keyword.take(meta, inspect_options())
    inspect_opts = Keyword.put_new(inspect_opts, :pretty, true)
    text = inspect(data, inspect_opts)
    text = "\n#{text}"

    text =
      case Keyword.fetch(meta, :label) do
        {:ok, label} -> "#{label}#{text}"
        _ -> text
      end

    meta = Keyword.drop(meta, inspect_options())
    Log.API.bare_log(text, meta)
    data
  end
end
