defmodule Log.Defaults do
  @moduledoc """
  Provides functions to get default runtime configuration
  """

  alias Log.Device
  alias Log.LevelFilter
  alias Log.Filter

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

  @spec tags() :: Filter.Tag.t()
  def tags do
    log_tags = System.get_env("LOG_TAGS", "")
    log_tags_level = System.get_env("LOG_TAGS_LEVEL", "")
    Filter.Tag.parse!({log_tags, log_tags_level})
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

  @spec module_alias() :: %{optional(module()) => String.t()}
  def module_alias do
    %{}
  end

  @spec exclude_namespaces() :: [module()]
  def exclude_namespaces do
    []
  end

  @spec format?() :: boolean()
  def format? do
    System.get_env("LOG_FORMATTERS", "on") == "on"
  end

  @spec module?() :: boolean()
  def module? do
    System.get_env("LOG_MODULE", "on") == "on"
  end

  @spec format_tags?() :: boolean()
  def format_tags? do
    System.get_env("LOG_FORMAT_TAGS", "off") == "on"
  end

  def put(%Log.Message{skip?: true} = message), do: message

  def put(%Log.Message{skip?: false} = message) do
    %{
      message
      | output_level: level(),
        output_device: device(),
        output_tags: tags(),
        format?: format?(),
        module?: module?(),
        utc?: utc?(),
        format_tags?: format_tags?()
    }
  end
end
