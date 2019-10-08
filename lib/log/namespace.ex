defmodule Log.Namespace do
  @moduledoc """
  Provides functions to determine module name prefix
  """

  @doc "Returns true if namespace is a prefix of module"
  @spec prefix?(module :: module(), namespace :: module()) :: boolean()
  def prefix?(module, namespace) do
    namespace = to_string(namespace)
    module = to_string(module)

    String.starts_with?(module, namespace)
  end
end
