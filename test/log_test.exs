defmodule LogTest do
  use ExUnit.Case

  defmodule Deeply.Nested.Module.WithLog do
    use Log.Macros, tags: [:use]

    @impl true
    def bare_log(chars_or_fun, meta) do
      IO.inspect({chars_or_fun, meta})
    end

    @log_tags [:other_tag]
    def hello do
      log(:error, "foo", tags: [:foo])
    end

    @log_tags [:special_other]
    def world do
      log(:error, "bar", tags: [:bar])
    end
  end

  test "foo" do
    Deeply.Nested.Module.WithLog.hello()
    Deeply.Nested.Module.WithLog.world()
  end
end
