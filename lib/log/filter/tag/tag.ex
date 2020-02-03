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

  def untagged, do: %__MODULE__{include_untagged?: true, must_exclude: :all}
  def tagged, do: %__MODULE__{}
  def all, do: %__MODULE__{include_untagged?: true}
  def default, do: tagged()

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

  @spec parse(tags :: String.t()) :: {:ok, t()} | {:error, String.t()}
  def parse(tags)
  def parse("_untagged"), do: {:ok, untagged()}
  def parse("_all"), do: {:ok, all()}
  def parse(""), do: {:ok, default()}

  def parse(tags) do
    tags
    |> String.split(",")
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&Filter.Tag.Name.parse/1)
    |> Enum.reduce({:ok, default()}, fn
      {:error, _} = err, _ -> err
      _, {:error, _} = err -> err
      {:ok, name}, {:ok, filter} -> put(filter, name)
    end)
  end

  @spec parse!(tags :: String.t()) :: t() | no_return()
  def parse!(tags) do
    case parse(tags) do
      {:error, msg} -> raise ArgumentError, msg
      {:ok, filter} -> filter
    end
  end

  @spec match?(filter :: t(), tags :: [Tag.t()]) :: boolean()
  def match?(%__MODULE__{} = filter, tags) do
    cond do
      Match.always?(tags) -> true
      Match.untagged?(tags) && filter.include_untagged? -> true
      true -> Match.filter?(filter, tags)
    end
  end
end
