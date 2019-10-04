defmodule Log.API do
  @callback bare_log(
              chars_or_fun :: String.t() | (() -> String.t()),
              meta :: keyword()
            ) :: any()

  def bare_log(chars_or_fun, meta) do
    level_filter = Log.Defaults.level()
    level = Keyword.fetch!(meta, :level)

    if Log.LevelFilter.match?(level_filter, level) do
      Logger.bare_log(:error, chars_or_fun, meta)
    end
  end

  defmacro log(module, level, chars_or_fun, meta) do
    tag =
      case Keyword.get(meta, :tag) do
        nil -> []
        single_tag -> [single_tag]
      end

    tags = Keyword.get(meta, :tags, [])
    func_tags = Module.get_attribute(__CALLER__.module, :log_tags, [])
    mod_tags = Module.get_attribute(__CALLER__.module, :log_module_tags, [])
    all_tags = List.flatten([tag, tags, func_tags, mod_tags])

    meta = Keyword.put(meta, :level, level)
    meta = Keyword.put(meta, :tags, all_tags)
    meta = Keyword.delete(meta, :tag)

    quote do
      unquote(module).bare_log(unquote(chars_or_fun), unquote(meta))
    end
  end

  defmacro def_log do
    quote(unquote: false, location: :keep) do
      module = __MODULE__

      defmacro log(level, chars_or_fun, meta) do
        module = unquote(module)

        quote do
          require Log.API

          Log.API.log(
            unquote(module),
            unquote(level),
            unquote(chars_or_fun),
            unquote(meta)
          )
        end
      end
    end
  end

  defmacro def_level_log(level) do
    quote(location: :keep) do
      defmacro unquote(level)(meta, do: block) do
        level = unquote(level)

        quote do
          log(
            unquote(level),
            fn -> unquote(block) end,
            unquote(meta)
          )
        end
      end

      defmacro unquote(level)(chars_or_fun, meta) do
        level = unquote(level)

        quote do
          log(
            unquote(level),
            unquote(chars_or_fun),
            unquote(meta)
          )
        end
      end

      defmacro unquote(level)(chars_or_fun) do
        level = unquote(level)

        quote do
          log(
            unquote(level),
            unquote(chars_or_fun),
            []
          )
        end
      end
    end
  end

  defmacro __using__(opts \\ []) do
    tags = Keyword.get(opts, :tags, [])

    [
      quote(location: :keep) do
        require unquote(__MODULE__)
        @behaviour unquote(__MODULE__)
        @log_module_tags unquote(tags)

        unquote(__MODULE__).def_log()
      end,
      quote(location: :keep, unquote: false) do
        require Log.API

        for level <- Log.Level.all() do
          Log.API.def_level_log(unquote(level))
        end
      end,
      quote(location: :keep) do
        @impl true
        def bare_log(chars_or_fun, meta) do
          unquote(__MODULE__).bare_log(chars_or_fun, meta)
        end

        defoverridable unquote(__MODULE__)
      end
    ]
    |> List.flatten()
  end
end
