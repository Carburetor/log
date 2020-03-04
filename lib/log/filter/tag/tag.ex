defmodule Log.Filter.Tag do
  alias Log.Filter
  alias Log.Filter.Tag.Match

  defstruct include_untagged?: false,
            one_of: :any,
            must_include: :none,
            must_exclude: :none,
            level: Log.Level.max()

  @type t :: %__MODULE__{
          include_untagged?: boolean(),
          one_of: :any | nonempty_list(Log.Tag.name()),
          must_include: :none | nonempty_list(Log.Tag.name()),
          must_exclude: :none | :all | nonempty_list(Log.Tag.name()),
          # Filter applied to this level and below
          level: Log.Level.t()
        }

  def all, do: %__MODULE__{include_untagged?: true}

  def default do
    {:ok, filter} = tagged()
    filter
  end

  def untagged(level_name \\ "_max") do
    filter = %__MODULE__{include_untagged?: true, must_exclude: :all}
    put_level(filter, level_name)
  end

  def tagged(level_name \\ "_max") do
    put_level(%__MODULE__{}, level_name)
  end

  @spec put(filter :: t(), name :: Filter.Tag.Name.t()) ::
          {:error, String.t()} | {:ok, t()}
  def put(filter, name)

  def put(%__MODULE__{} = _filter, :all) do
    {:error, "_all must be the only tag"}
  end

  def put(%__MODULE__{} = filter, :untagged) do
    {:ok, %{filter | include_untagged?: true}}
  end

  def put(%__MODULE__{must_include: :none} = filter, {:+, tag}) do
    {:ok, %{filter | must_include: [tag]}}
  end

  def put(%__MODULE__{must_include: some} = filter, {:+, tag}) do
    {:ok, %{filter | must_include: [tag | some]}}
  end

  def put(%__MODULE__{must_exclude: :none} = filter, {:-, tag}) do
    {:ok, %{filter | must_exclude: [tag]}}
  end

  def put(%__MODULE__{must_exclude: :all}, {:-, tag}) do
    {:error, "All tags are already excluded, can't exclude `#{tag}`"}
  end

  def put(%__MODULE__{must_exclude: some} = filter, {:-, tag}) do
    {:ok, %{filter | must_exclude: [tag | some]}}
  end

  def put(%__MODULE__{one_of: :any} = filter, {:tag, tag}) do
    {:ok, %{filter | one_of: [tag]}}
  end

  def put(%__MODULE__{one_of: some} = filter, {:tag, tag}) do
    {:ok, %{filter | one_of: [tag | some]}}
  end

  @spec put_level(t(), String.t()) :: {:error, String.t()} | {:ok, t()}
  def put_level(%__MODULE__{} = filter, level_name) do
    case Log.Level.Name.parse(level_name) do
      {:error, _} = err -> err
      {:ok, level} -> {:ok, %{filter | level: level}}
    end
  end

  @spec put_tags(t(), String.t()) :: {:error, String.t()} | {:ok, t()}
  def put_tags(%__MODULE__{} = filter, tags) do
    tags
    |> String.split(",")
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&Filter.Tag.Name.parse/1)
    |> Enum.reduce({:ok, filter}, fn
      {:error, _} = err, _ok_new_filter -> err
      _ok_tag, {:error, _} = err -> err
      {:ok, name}, {:ok, new_filter} -> put(new_filter, name)
    end)
  end

  @spec parse(tags :: {String.t(), String.t()}) ::
          {:ok, t()} | {:error, String.t()}
  def parse(tags)
  def parse({"_untagged", level_name}), do: untagged(level_name)
  def parse({"_all", _level_name}), do: {:ok, all()}
  def parse({"", ""}), do: {:ok, default()}
  def parse({"", level_name}), do: tagged(level_name)
  def parse({tags, ""}), do: parse({tags, "_max"})

  def parse({tags, level_name}) do
    case tagged(level_name) do
      {:error, _} = err -> err
      {:ok, tagged_filter} -> put_tags(tagged_filter, tags)
    end
  end

  @spec parse!(tags_and_level_name :: {String.t(), String.t()}) ::
          t() | no_return()
  def parse!({_tags, _level_name} = tags_and_level_name) do
    case parse(tags_and_level_name) do
      {:error, msg} -> raise ArgumentError, msg
      {:ok, filter} -> filter
    end
  end

  @spec match?(filter :: t(), tags :: {Log.Tag.List.t(), Log.Level.t()}) ::
          boolean()
  def match?(%__MODULE__{} = filter, {tags, level}) do
    cond do
      Filter.Tag.Level.below_or_equal_to?(filter, level) -> true
      Match.always?(tags) -> true
      Match.untagged?(tags) && filter.include_untagged? -> true
      true -> Match.filter?(filter, tags)
    end
  end
end
