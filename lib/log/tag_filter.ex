defmodule Log.TagFilter do
  alias Log.TagFilter

  @type t ::
          TagFilter.Named.t()
          | TagFilter.Untagged.t()
          | TagFilter.Tagged.t()

  @spec parse(tag :: String.t()) :: t() | {:error, String.t()}
  def parse(tag)
  def parse("_untagged"), do: %TagFilter.Untagged{}
  def parse("-_untagged"), do: {:error, "-_untagged is not a valid filter"}
  def parse("_all"), do: %TagFilter.Tagged{}
  def parse("-_all"), do: {:error, "-_all is not a valid filter"}
  def parse("_" <> _ = text), do: {:error, "Filter \"#{text}\" begins with _"}
  def parse("--" <> _), do: {:error, "Multiple dashes at start of filter"}
  def parse(""), do: {:error, "Filter is empty"}

  def parse("-" <> name) do
    case parse(name) do
      %TagFilter.Named{} = filter -> %{filter | exclude?: true}
      {:error, _} = error -> error
    end
  end

  def parse(text) do
    case Log.Tag.parse(text) do
      {:error, _} = error -> error
      name -> %TagFilter.Named{name: name}
    end
  end

  @spec parse!(tag :: String.t()) :: t() | no_return()
  def parse!(tag) do
    case parse(tag) do
      {:error, msg} -> raise ArgumentError, msg
      result -> result
    end
  end
end
