defmodule Log.ModuleAlias do
  @type t :: %{optional(module()) => String.t()}
  @type sorted :: [{module(), String.t()}]

  @spec replace(module :: module(), aliases :: t()) :: String.t()
  def replace(module, %{} = aliases) do
    name = to_string(module)
    sorted_aliases = sort(aliases)

    new_name =
      Enum.reduce(sorted_aliases, name, fn {mod_alias, mod_replace}, name ->
        alias_name = module_name(mod_alias)

        String.replace(name, alias_name, mod_replace, global: false)
      end)

    new_name
    |> module_name()
    |> String.replace_leading(".", "")
  end

  @spec sort(aliases :: t()) :: sorted()
  def sort(%{} = aliases) do
    aliases
    |> Enum.to_list()
    |> Enum.sort_by(fn {mod, _} -> String.length(to_string(mod)) end, &>=/2)
  end

  @spec module_name(module :: module() | String.t()) :: String.t()
  def module_name(module) do
    module
    |> to_string()
    |> String.replace_leading("Elixir.", "")
  end
end
