defmodule Log.TagFilter do
  @moduledoc """
  Provides functions to parse a tag filter from a string
  """

  alias Log.TagFilter
  alias Log.Tag
  alias Log.Tag.Always

  import Kernel, except: [match?: 2]

  @type t ::
          TagFilter.Named.t()
          | TagFilter.Untagged.t()
          | TagFilter.Tagged.t()
          | TagFilter.MustExcludeNamed.t()
          | TagFilter.MustIncludeNamed.t()

  @spec parse(tag :: String.t()) :: t() | {:error, String.t()}
  def parse(tag)
  def parse("_untagged"), do: %TagFilter.Untagged{}
  def parse("-_untagged"), do: {:error, "-_untagged is not a valid filter"}
  def parse("+_untagged"), do: {:error, "+_untagged is not a valid filter"}
  def parse("_all"), do: %TagFilter.Tagged{}
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
      %TagFilter.Named{} = filter ->
        %TagFilter.MustExcludeNamed{name: filter.name}

      {:error, _} = error ->
        error
    end
  end

  def parse("+" <> name) do
    case parse(name) do
      %TagFilter.Named{} = filter ->
        %TagFilter.MustIncludeNamed{name: filter.name}

      {:error, _} = error ->
        error
    end
  end

  def parse(text) do
    tag = String.to_atom(text)

    case Log.Tag.parse(tag) do
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

  @spec match?(filter :: t(), tag :: Tag.t() | [Tag.t()]) :: boolean()
  def match?(filter, tag_or_tags)
  def match?(%TagFilter.Untagged{}, []), do: true
  def match?(%TagFilter.Untagged{}, [_ | _] = tags), do: %Always{} in tags
  def match?(%TagFilter.Tagged{}, []), do: false
  def match?(%TagFilter.Tagged{}, [_ | _]), do: true
  def match?(%TagFilter.Named{}, []), do: false
  def match?(%TagFilter.MustExcludeNamed{}, []), do: false
  def match?(%TagFilter.MustIncludeNamed{}, []), do: false

  def match?(%TagFilter.Named{} = filter, tags) when is_list(tags) do
    cond do
      %Always{} in tags -> true
      true -> filter.name in tags
    end
  end

  def match?(%TagFilter.MustExcludeNamed{} = filter, tags) when is_list(tags) do
    cond do
      %Always{} in tags -> true
      true -> !(filter.name in tags)
    end
  end

  def match?(%TagFilter.MustIncludeNamed{} = filter, tags) when is_list(tags) do
    cond do
      %Always{} in tags -> true
      true -> filter.name in tags
    end
  end
end
