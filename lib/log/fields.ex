defmodule Log.Fields do
  @moduledoc """
  Provides logging for simple data structures in a human-readable fashion.
  It's meant to be used for manually-provided data structures with 1-4
  fields:

  ```
  require Log.Fields
  Log.Fields.info({"a message", %{some_id: 123, some_name: "Jon"}})
  ```

  Will output

  ```
  [2000-01-01T01:01:01.001Z] INFO: a message (SomeId: 123, SomeName: Jon)
  ```

  If `String` keys are used, no transformation to pascal case is performed.
  It's possible to use a keyword instead of a map.
  """

  use Log, tags: [:fields]

  @impl true
  def bare_log(data, meta)

  def bare_log(data, meta) when is_function(data) do
    force_log(fn -> data.() |> build_text() end, meta)
  end

  def bare_log(data, meta) do
    force_log(fn -> build_text(data) end, meta)
  end

  def force_log(fun, meta) do
    Log.API.bare_log(fun, meta)
  end

  def build_text({msg, data}) do
    case Enum.empty?(data) do
      true ->
        msg

      false ->
        text_data = to_pascal(data)
        "#{msg} (#{text_data})"
    end
  end

  def to_pascal(data) do
    data
    |> Enum.map(fn {key, value} ->
      case key do
        key_name when is_binary(key_name) ->
          {key_name, value}

        key_name ->
          key_name = to_string(key_name)
          key_name = Log.Casing.to_pascal(key_name)
          {key_name, value}
      end
    end)
    |> Enum.map(fn {key, value} -> "#{key}: #{value}" end)
    |> Enum.join(", ")
  end
end
