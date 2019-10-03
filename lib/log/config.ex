defmodule Log.Config do
  defstruct colors: %{}, module_alias: %{}

  alias Log.Level
  alias Log.Color

  @type t :: %__MODULE__{
          colors: %{optional(Level.t()) => Color.t()},
          module_alias: Log.ModuleAlias.t()
        }
  @type color_opts :: %{optional(Level.t()) => Color.t()}
  @type module_alias_opts :: Log.ModuleAlias.t()

  @spec build(
          opts :: [
            {:colors, color_opts()} | {:module_alias, module_alias_opts()}
          ]
        ) :: t()
  def build(opts \\ []) do
    opts = Keyword.put_new(opts, :colors, Log.Defaults.colors())
    opts = Keyword.put_new(opts, :module_alias, Log.Defaults.module_alias())

    colors = Keyword.get(opts, :colors)
    module_alias = Keyword.get(opts, :module_alias)

    %__MODULE__{colors: colors, module_alias: module_alias}
  end

  @spec get_color(config :: t(), level :: Level.t()) :: Color.t()
  def get_color(%__MODULE__{colors: colors}, level) do
    case Map.get(colors, level, [IO.ANSI.normal()]) do
      list when is_list(list) -> list
      not_list -> [not_list]
    end
  end
end
