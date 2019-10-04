defmodule Log.API do
  @callback default_tags() :: [atom()]
  @callback bare_log(
              data :: any() | (() -> any()),
              meta :: keyword()
            ) :: any()

  @spec bare_log(
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

  def get_default_meta(caller_env) do
    {fun_name, fun_arity} = caller_env.function

    [
      line: caller_env.line,
      function: "#{fun_name}/#{fun_arity}",
      module: caller_env.module,
      file: caller_env.file,
      application: :application.get_application(caller_env.module)
    ]
  end

  @spec get_fixed_tags(definer :: module(), caller :: module) :: [atom()]
  def get_fixed_tags(definer, caller) do
    func_tags = Module.get_attribute(caller, :log_tags, [])
    mod_tags = definer.default_tags()

    func_tags ++ mod_tags
  end

  def put_fixed_tags(meta, fixed_tags) do
    tags = Keyword.get(meta, :tags, [])
    Keyword.put(meta, :tags, tags ++ fixed_tags)
  end

  def get_base_meta(definer, caller_env) do
    base_meta = get_default_meta(caller_env)
    fixed_tags = get_fixed_tags(definer, caller_env.module)
    put_fixed_tags(base_meta, fixed_tags)
  end

  def put_base_meta(meta, base_meta) do
    fixed_tags = Keyword.get(base_meta, :tags, [])
    base_meta = Keyword.delete(base_meta, :tags)
    meta = Keyword.merge(base_meta, meta)
    put_fixed_tags(meta, fixed_tags)
  end

  def put_level(meta, level) do
    Keyword.put(meta, :level, level)
  end

  def log(module, level, chars_or_fun, meta) do
    meta = __MODULE__.put_level(meta, level)
    module.bare_log(chars_or_fun, meta)
  end

  def def_log do
    quote(location: :keep) do
      defmacro log(level, chars_or_fun, meta) do
        root = unquote(__MODULE__)
        base_meta = root.get_base_meta(__MODULE__, __CALLER__)

        quote do
          unquote(root).log(
            unquote(__MODULE__),
            unquote(level),
            unquote(chars_or_fun),
            unquote(root).put_base_meta(unquote(meta), unquote(base_meta))
          )
        end
      end
    end
  end

  def def_level_log(level) do
    quote(location: :keep) do
      defmacro unquote(level)(meta, do: block) do
        level = unquote(level)

        quote do
          unquote(__MODULE__).log(
            unquote(level),
            fn -> unquote(block) end,
            unquote(meta)
          )
        end
      end

      defmacro unquote(level)(chars_or_fun, meta) do
        level = unquote(level)

        quote do
          unquote(__MODULE__).log(
            unquote(level),
            unquote(chars_or_fun),
            unquote(meta)
          )
        end
      end

      defmacro unquote(level)(chars_or_fun) do
        level = unquote(level)

        quote do
          unquote(__MODULE__).log(
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
        @behaviour unquote(__MODULE__)

        @impl true
        def default_tags, do: unquote(tags)

        @impl true
        def bare_log(chars_or_fun, meta) do
          unquote(__MODULE__).bare_log(chars_or_fun, meta)
        end

        defoverridable unquote(__MODULE__)
      end,
      __MODULE__.def_log(),
      for level <- Log.Level.all() do
        __MODULE__.def_level_log(level)
      end
    ]
    |> List.flatten()
  end
end
