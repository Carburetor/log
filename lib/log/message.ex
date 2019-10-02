defmodule Log.Message do
  defstruct output_level: %Log.LevelFilter.None{},
            output_device: :standard_error,
            output_tags: [],
            config: %Log.Config{},
            level: Log.Level.min(),
            timestamp: nil,
            text: "",
            tags: [],
            skip?: false

  @type t :: map()

  def build({level, _gl, {Logger, text, timestamp, meta}}) do
    %__MODULE__{text: text, timestamp: timestamp}
    |> put_level(level, meta)
    |> put_tags(meta)
  end

  def put_level(%__MODULE__{} = message, level, meta) do
    case Log.Level.parse(meta[:level] || level) do
      {:error, msg} ->
        IO.inspect({meta, level, msg})
        skip(message)

      parsed_level ->
        %{message | level: parsed_level}
    end
  end

  def put_tags(%__MODULE__{} = message, meta) do
    tags =
      case Keyword.get(meta, :tag) do
        nil ->
          Keyword.get(meta, :tags, [])

        tag ->
          tags = Keyword.get(meta, :tags, [])
          [tag | tags]
      end

    case Log.Tags.parse(tags) do
      {:error, _} -> skip(message)
      parsed_tags -> %{message | tags: parsed_tags}
    end
  end

  def skip(%__MODULE__{} = message), do: %{message | skip?: true}

  def put_config(%__MODULE__{} = message, config) do
    %{message | config: config}
  end
end
