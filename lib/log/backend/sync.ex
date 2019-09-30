defmodule Log.Backend.Sync do
  @moduledoc false

  @behaviour :gen_event

  defstruct colors: %{}, level: nil, device: :standard_error

  def init(__MODULE__) do
    init({__MODULE__, []})
  end

  def init({__MODULE__, opts}) when is_list(opts) do
    device = Keyword.get(opts, :device, :standard_error)

    if Process.whereis(device) do
      {:ok, configure(opts)}
    else
      {:error, :ignore}
    end
  end

  def configure(opts, state \\ %__MODULE__{}) when is_list(opts) do
    level = Keyword.get(opts, :level, :debug)
    device = Keyword.get(opts, :device, :standard_error)

    %{state | level: level, device: device}
  end

  def handle_call({:configure, opts}, state) do
    {:ok, :ok, configure(opts, state)}
  end

  def handle_event({_level, gl, _event}, state) when node(gl) != node() do
    {:ok, state}
  end

  def handle_event({_level, _gl, {Logger, msg, _ts, _md}}, state) do
    %{
      level: _allowed_level,
      device: device
    } = state

    # level = md[:level] || level

    Log.IO.Sync.write(device, msg)

    # cond do
    #   not meet_level?(level, log_level) ->
    #     {:ok, state}

    #   is_nil(ref) ->
    #     {:ok, log_event(level, msg, ts, md, state)}

    #   buffer_size < max_buffer ->
    #     {:ok, buffer_event(level, msg, ts, md, state)}

    #   buffer_size === max_buffer ->
    #     state = buffer_event(level, msg, ts, md, state)
    #     {:ok, await_io(state)}
    # end
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
end
