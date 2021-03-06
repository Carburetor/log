defmodule Log.Backend do
  @moduledoc """
  Provides `Logger` backend for console logging functionality with output
  filtering through environment variables
  """

  alias Log.Config

  @behaviour :gen_event

  defstruct config: %Config{}

  def init(__MODULE__) do
    init({__MODULE__, []})
  end

  def init({__MODULE__, opts}) when is_list(opts) do
    {:ok, configure(opts)}
  end

  def configure(opts, state \\ %__MODULE__{}) when is_list(opts) do
    config = Config.build(opts)

    %{state | config: config}
  end

  def handle_call({:configure, opts}, state) do
    {:ok, :ok, configure(opts, state)}
  end

  def handle_event({_level, gl, _event}, state) when node(gl) != node() do
    {:ok, state}
  end

  def handle_event({_level, _gl, {Logger, _text, _ts, _meta}} = msg, state) do
    msg
    |> Log.Message.build()
    |> Log.Defaults.put()
    |> Log.Message.put_config(state.config)
    |> Log.Filter.by_level()
    |> Log.Filter.by_tag_filters()
    |> Log.Filter.by_namespaces()
    |> Log.IO.Standard.write()
    |> debug_message()

    {:ok, state}
  rescue
    err ->
      if System.get_env("LOG_DEBUG", "off") == "on" do
        error_message = Exception.format(:error, err, __STACKTRACE__)
        IO.puts(error_message)
      end

      raise err
  end

  def handle_event(:flush, state) do
    {:ok, state}
  end

  def handle_event(_, state) do
    {:ok, state}
  end

  def handle_info({:DOWN, _ref, _, pid, reason}, _) do
    raise "device #{inspect(pid)} exited: " <> Exception.format_exit(reason)
  end

  def handle_info(_, state) do
    {:ok, state}
  end

  def code_change(_old_vsn, state, _extra) do
    {:ok, state}
  end

  def terminate(_reason, _state) do
    :ok
  end

  def debug_message(message) do
    if System.get_env("LOG_DEBUG", "off") == "on" do
      IO.inspect(message, label: "[Log DEBUG]")
    end

    message
  end
end
