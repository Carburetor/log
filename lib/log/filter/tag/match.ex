defmodule Log.Filter.Tag.Match do
  alias Log.Tag.Always
  alias Log.Filter.Tag

  @type t :: :ignore | :match | :mismatch

  @spec always?(tags :: [Log.Tag.t()]) :: boolean()
  def always?(tags) do
    %Always{} in tags
  end

  @spec untagged?(tags :: [Log.Tag.t()]) :: boolean()
  def untagged?([]), do: true
  def untagged?([_ | _]), do: false

  @spec filter?(filter :: Tag.t(), tags :: [Log.Tag.t()]) :: boolean()
  def filter?(%Tag{} = filter, tags) do
    [
      one_of(filter.one_of, tags),
      must_include(filter.must_include, tags),
      must_exclude(filter.must_exclude, tags)
    ]
    |> Enum.reject(&(&1 == :ignore))
    |> Enum.all?(&(&1 == :match))
  end

  @spec one_of(
          some :: :any | nonempty_list(Log.Tag.name()),
          tags :: [Log.Tag.t()]
        ) :: t()
  def one_of(some, tags)
  def one_of(:any, _), do: :ignore

  def one_of(list, tags) when is_list(list) do
    case Enum.any?(list, &(&1 in tags)) do
      true -> :match
      false -> :mismatch
    end
  end

  @spec must_include(
          some :: :none | nonempty_list(Log.Tag.name()),
          tags :: [Log.Tag.t()]
        ) :: t()
  def must_include(some, tags)
  def must_include(:none, _), do: :ignore

  def must_include(list, tags) when is_list(list) do
    case Enum.all?(list, &(&1 in tags)) do
      true -> :match
      false -> :mismatch
    end
  end

  @spec must_exclude(
          some :: :none | :all | nonempty_list(Log.Tag.name()),
          tags :: [Log.Tag.t()]
        ) :: t()
  def must_exclude(some, tags)
  def must_exclude(:none, _), do: :ignore
  def must_exclude(:all, []), do: :match
  def must_exclude(:all, [_ | _]), do: :mismatch

  def must_exclude(list, tags) when is_list(list) do
    case Enum.any?(list, &(&1 in tags)) do
      true -> :mismatch
      false -> :match
    end
  end
end
