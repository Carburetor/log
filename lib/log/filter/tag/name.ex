defmodule Log.Filter.Tag.Name do
  alias Log.Tag

  @type t ::
          {:tag, Tag.name()}
          | {:+, Tag.name()}
          | {:-, Tag.name()}
          | :untagged
          | :all

  @spec parse(tag :: String.t()) :: {:ok, t()} | {:error, String.t()}
  def parse(tag)
  def parse("_untagged"), do: {:ok, :untagged}
  def parse("-_untagged"), do: {:error, "-_untagged is not a valid filter"}
  def parse("+_untagged"), do: {:error, "+_untagged is not a valid filter"}
  def parse("_all"), do: {:ok, :all}
  def parse("-_all"), do: {:error, "-_all is not a valid filter"}
  def parse("+_all"), do: {:error, "+_all is not a valid filter"}
  def parse("_" <> _ = text), do: {:error, "Filter \"#{text}\" begins with _"}
  def parse("--" <> _), do: {:error, "Multiple dashes at start of filter"}
  def parse("++" <> _), do: {:error, "Multiple plus at start of filter"}
  def parse("-+" <> _), do: {:error, "Multiple modifiers at start of filter"}
  def parse("+-" <> _), do: {:error, "Multiple modifiers at start of filter"}
  def parse(""), do: {:error, "Filter is empty"}

  def parse("-" <> name) do
    case parse(name) do
      {:ok, {:tag, tag_name}} -> {:ok, {:-, tag_name}}
      {:error, _} = error -> error
    end
  end

  def parse("+" <> name) do
    case parse(name) do
      {:ok, {:tag, tag_name}} -> {:ok, {:+, tag_name}}
      {:error, _} = error -> error
    end
  end

  def parse(name) do
    {:ok, {:tag, String.to_atom(name)}}
  end

  @spec parse!(tag :: String.t()) :: t() | no_return()
  def parse!(tag) do
    case parse(tag) do
      {:error, msg} -> raise ArgumentError, msg
      {:ok, tag_name} -> tag_name
    end
  end
end
