defmodule Log.Macros do
  @callback bare_log(
              chars_or_fun :: String.t() | (() -> String.t()),
              meta :: keyword()
            ) :: any()

  defmacro log(level, chars_or_fun, meta) do
    meta = Keyword.put(meta, :level, level)
    tag = Keyword.get(meta, :tag)

    tags =
      case tag do
        nil -> Keyword.get(meta, :tags, [])
        _ -> [tag | Keyword.get(meta, :tags, [])]
      end

    module_tags = Module.get_attribute(__CALLER__.module, :log_tags, [])
    use_tags = Module.get_attribute(__CALLER__.module, :__log_tags__, [])
    meta = Keyword.put(meta, :tags, tags ++ module_tags ++ use_tags)
    meta = Keyword.delete(meta, :tag)

    quote do
      bare_log(unquote(chars_or_fun), unquote(meta))
    end
  end

  defmacro __using__(opts \\ []) do
    tags = Keyword.get(opts, :tags, [])

    quote(bind_quoted: [use_tags: tags]) do
      @behaviour Log.Macros
      @__log_tags__ use_tags

      defmacro log(level, chars_or_fun, meta \\ []) do
        quote do
          Log.Macros.log(
            unquote(level),
            unquote(chars_or_fun),
            unquote(meta)
          )
        end
      end

      @impl true
      def bare_log(chars_or_fun, meta) do
        Logger.bare_log(:error, chars_or_fun, meta)
      end

      defoverridable Log.Macros
    end
  end
end
