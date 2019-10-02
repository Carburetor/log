defmodule Log.Defaults do
  alias Log.Device
  alias Log.LevelFilter
  alias Log.TagFilters

  @spec level() :: LevelFilter.t()
  def level do
    "LOG_LEVEL"
    |> System.get_env("info")
    |> LevelFilter.parse!()
  end

  @spec device() :: Device.t()
  def device do
    "CONSOLE_DEVICE"
    |> System.get_env("stderr")
    |> Device.parse!()
  end

  @spec tags() :: TagFilters.t()
  def tags do
    "LOG_TAGS"
    |> System.get_env("")
    |> TagFilters.parse!()
  end

  @spec utc?() :: boolean()
  def utc? do
    Application.get_env(:logger, :utc_log, false)
  end

  @spec colors() :: %{optional(Log.Level.t()) => Log.Color.t()}
  def colors do
    %{
      trace: [IO.ANSI.cyan()],
      debug: [IO.ANSI.green()],
      info: [IO.ANSI.normal()],
      warn: [IO.ANSI.yellow(), IO.ANSI.black_background()],
      error: [IO.ANSI.red(), IO.ANSI.bright()],
      fatal: [IO.ANSI.red(), IO.ANSI.black_background()]
    }
  end

  def put(%Log.Message{skip?: true} = message), do: message

  def put(%Log.Message{skip?: false} = message) do
    %{
      message
      | output_level: level(),
        output_device: device(),
        output_tags: tags(),
        utc?: utc?()
    }
  end
end
