defmodule Log.Inspect do
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
      :custom_options
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
    meta = Keyword.drop(meta, inspect_options())
    text = inspect(data, inspect_opts)
    text = "\n#{text}"
    Log.API.bare_log(text, meta)
  end
end
