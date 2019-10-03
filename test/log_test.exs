defmodule LogTest do
  use ExUnit.Case
  require Logger

  defmodule Deeply.Nested.Module.WithLog do
    def log do
      Logger.error("foo", tags: [:foo])
    end
  end

  test "foo" do
    Deeply.Nested.Module.WithLog.log()
  end
end
