defmodule Log.Defaults do
  alias Log.Device
  alias Log.Level

  @spec level() :: Level.t()
  def level do
    "LOG_LEVEL"
    |> System.get_env("info")
    |> Level.parse!()
  end

  @spec device() :: Device.t()
  def device do
    "CONSOLE_DEVICE"
    |> System.get_env("stderr")
    |> Device.parse!()
  end

  def put(%Log.Message{skip?: true} = message), do: message

  def put(%Log.Message{skip?: false} = message) do
    %{message | output_level: level(), output_device: device()}
  end
end
