defmodule LogTest do
  use ExUnit.Case

  defmodule Special do
    def hello do
      IO.puts("inside hello")
      "asd"
    end
  end

  defmodule Deeply.Nested.Module.WithLog do
    # use Log.API, tags: [:use]
    require Log

    # @impl true
    # def bare_log(chars_or_fun, meta) do
    #   IO.inspect({chars_or_fun, meta})
    # end

    @log_tags [:other_tag]
    def hello do
      # log(:error, "foo", tags: [:foo])
    end

    @log_tags [:special_other]
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
      Log.debug(&Special.hello/0)
      # log(:error, "foo", tags: [:sdfs])
    end
  end

  test "foo" do
    # require Deeply.Nested.Module.WithLog
    # Deeply.Nested.Module.WithLog.log(:warn, "foo", tags: [:whatever])
    # Deeply.Nested.Module.WithLog.hello()
    Deeply.Nested.Module.WithLog.world()
  end
end
