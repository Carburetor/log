defmodule Log.Config do
  defstruct colors: %{}

  alias Log.Level
  alias Log.Color

  @type t :: %__MODULE__{
          colors: %{optional(Level.t()) => Color.t()}
        }
  @type color_opts :: %{optional(Level.t()) => Color.t()}

  @spec build(opts :: [{:colors, color_opts()}]) :: t()
  def build(opts \\ []) do
    opts = Keyword.put_new(opts, :colors, Log.Defaults.colors())

    colors = Keyword.get(opts, :colors)

    %__MODULE__{colors: colors}
  end

  @spec get_color(config :: t(), level :: Level.t()) :: Color.t()
  def get_color(%__MODULE__{colors: colors}, level) do
    case Map.get(colors, level, [IO.ANSI.normal()]) do
      list when is_list(list) -> list
      not_list -> [not_list]
    end
  end
end
