defmodule Log.Message do
  @moduledoc """
  Provides a datastructure that holds all the information related to an
  incoming log message that needs to output
  """

  defstruct output_level: %Log.LevelFilter.None{},
            output_device: :standard_error,
            output_tags: Log.Filter.Tag.default(),
            config: %Log.Config{},
            level: Log.Level.min(),
            timestamp: NaiveDateTime.new(1, 1, 1, 0, 0, 0) |> elem(1),
            text: "",
            tags: [],
            module: nil,
            format?: true,
            module?: true,
            utc?: false,
            format_tags?: false,
            skip?: false,
            skip_reason: ""

  @type t :: %__MODULE__{
          output_level: Log.LevelFilter.t(),
          output_device: :standard_error | :standard_output,
          output_tags: Log.Filter.Tag.t(),
          config: Log.Config.t(),
          level: Log.Level.t(),
          timestamp: NaiveDateTime.t(),
          text: String.t(),
          tags: [Log.Tag.t()],
          module: nil | module(),
          format?: boolean(),
          module?: boolean(),
          utc?: boolean(),
          format_tags?: boolean(),
          skip?: boolean(),
          skip_reason: String.t()
        }

  def build({level, _gl, {Logger, text, timestamp, meta}}) do
    %__MODULE__{text: text}
    |> put_level(level, meta)
    |> put_tags(meta)
    |> put_timestamp(timestamp)
    |> put_module(meta)
  end

  def put_level(%__MODULE__{} = message, level, meta) do
    case Log.Level.parse(meta[:level] || level) do
      {:error, msg} ->
        skip(
          message,
          "Error parsing message level: #{inspect({meta, level, msg})}"
        )

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

    case Log.Tag.List.parse(tags) do
      {:error, _} ->
        skip(message, "Error parsing message tags: #{inspect(tags)}")

      parsed_tags ->
        %{message | tags: parsed_tags}
    end
  end

  def put_timestamp(%__MODULE__{} = message, timestamp) do
    case Log.Timestamp.parse(timestamp) do
      {:error, _} ->
        skip(
          message,
          "Error parsing message timestamp #{inspect(timestamp)}"
        )

      date ->
        %{message | timestamp: date}
    end
  end

  def put_module(%__MODULE__{} = message, meta) do
    module = meta[:module]
    %{message | module: module}
  end

  def skip(%__MODULE__{} = message), do: %{message | skip?: true}

  def skip(%__MODULE__{} = message, reason) do
    %{message | skip?: true, skip_reason: reason}
  end

  def put_config(%__MODULE__{} = message, config) do
    %{message | config: config}
  end
end
