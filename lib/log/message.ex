defmodule Log.Message do
  defstruct output_level: :none,
            output_device: :standard_error,
            config: %Log.Config{},
            level: :none,
            timestamp: nil,
            text: "",
            skip?: false

  @type t :: map()

  def build({level, _gl, {Logger, text, timestamp, meta}}) do
    message = %__MODULE__{text: text, timestamp: timestamp}

    case Log.Level.parse(meta[:level] || level) do
      :error -> skip(message)
      parsed_level -> %{message | level: parsed_level}
    end
  end

  def skip(%__MODULE__{} = message), do: %{message | skip?: true}

  def put_config(%__MODULE__{} = message, config) do
    %{message | config: config}
  end
end
