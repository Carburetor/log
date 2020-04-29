defmodule LogTest do
  use ExUnit.Case

  defmodule Special do
    def hello do
      IO.puts("inside hello")
      "asd"
    end
  end

  defmodule MyLog do
    use Log, tags: [:mylog]
  end

  defmodule Deeply.Nested.Module.WithLog do
    # use Log.API, tags: [:use]
    require MyLog
    require Log.Inspect
    require Log.Args
    require Log
    require Logger
    require Log.Passthrough

    # @impl true
    # def bare_log(chars_or_fun, meta) do
    #   IO.inspect({chars_or_fun, meta})
    # end

    @log_tags [:other_tag]
    def hello do
      # log(:error, "foo", tags: [:foo])
    end

    # @log_tags [:special_other]
    @log_tags []
    def world do
      # log(:error, fn -> "bar" end, tags: [:bar])
      # debug("foo", tags: [:bar])
      # error("foo", tags: [:bar])
      # error("foo")

      # debug(tags: [:bar]) do
      #   "fooasd #{inspect(IO.puts("wtf"))}"
      # end

      # debug(
      #   fn ->
      #     "fooasd #{inspect(IO.puts("wtf"))}"
      #   end,
      #   tags: [:foobar]
      # )

      # debug(fn ->
      #   "fooasd #{inspect(IO.puts("wtf"))}"
      # end)

      # Log.__info__(:macros) |> IO.inspect()
      # Log.info(&Special.hello/0, tags: [:somethingplus], what: fn -> 123 end)
      # Log.info(&Special.hello/0)

      # Log.info tags: [:boom] do
      #   Special.hello()
      # end

      # Log.log(:info, &Special.hello/0, tags: [:whatboom])
      # MyLog.fatal(&Special.hello/0, tag: :boom2)
      # Log.Inspect.info(%{some: 123}, label: "whatever")
      # Log.Data.info({"Special message", %{some: 123, what_ever: 444}},
      #   tags: [:special_data]
      # )

      # log(:error, "foo", tags: [:sdfs])

      # Log.info tags: [:boom] do
      #   "dsfgjidfg"
      # end

      # Log.info("asdasd", tags: [:foo, :boom])
      # Logger.info(fn -> "these" end, tags: [:boom])

      # Log.info(tags: [:boom]) do
      #   "sdfsdf"
      # end

      # Log.Inspect.info(%{data: 123}, label: "whatever")
      # Log.Args.info({"this is a message", %{some_data: 123}})

      # Log.Args.info(fn -> {"this is a message", %{some_data: 123}} end,
      #   tags: [:something]
      # )

      # Log.Args.info(fn -> {"this is a message", %{some_data: 123}} end)
      # Log.Args.info({"this is a message", %{some_data: 123}})

      # Log.Args.info tags: [:something] do
      #   {"this is a message", %{some_data: 123}}
      # end

      # Log.Args.info do
      #   {"this is a message", %{some_data: 123}}
      # end

      Logger.info("This is an untagged message")
      Logger.error("This is an untagged message")
      Log.info("This is an untagged message with Log")
      Log.info("This message tag :foo, :bar", tags: [:foo, :bar])
      Log.info("This message tag :foo, :bar, :baz", tags: [:foo, :bar, :baz])
      Log.warn("This message tag :foo", tags: [:foo])
      Log.info("This message tag :bar", tags: [:bar])
      Log.info("This message tag :bar, :baz", tags: [:bar, :baz])
      Log.Passthrough.info(123, label: "A passthrough message")
    end
  end

  test "foo" do
    # require Deeply.Nested.Module.WithLog
    # Deeply.Nested.Module.WithLog.log(:warn, "foo", tags: [:whatever])
    # Deeply.Nested.Module.WithLog.hello()
    Deeply.Nested.Module.WithLog.world()
  end
end
