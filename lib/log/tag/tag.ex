defmodule Log.Tag do
  @moduledoc """
  Provides function to parse an atom into a `Log.Tag.t()`
  """

  import Kernel, except: [to_string: 1]

  alias Log.Tag.Always

  @type name :: atom()
  @type t :: name() | Always.t()

  @spec parse(tag :: atom()) :: t() | {:error, String.t()}
  def parse(tag)
  def parse(:*), do: %Always{}

  def parse(tag) when not is_atom(tag) do
    {:error, "Tag must be an atom: #{tag}"}
  end

  def parse(tag) when is_atom(tag) do
    case Kernel.to_string(tag) do
      "+" <> _ -> {:error, "Tag must not start with +"}
      "-" <> _ -> {:error, "Tag must not start with -"}
      "_" <> _ -> {:error, "Tag must not start with _"}
      _ -> tag
    end
  end

  @spec parse!(tag :: atom()) :: t() | no_return()
  def parse!(tag) do
    case parse(tag) do
      {:error, msg} -> raise ArgumentError, msg
      result -> result
    end
  end

  @spec to_string(tag :: t()) :: String.t()
  def to_string(%Always{}), do: ":*"
  def to_string(name) when is_atom(name), do: ":#{name}"
end
