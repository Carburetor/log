defmodule LogTest do
  use ExUnit.Case
  require Logger

  test "foo" do
    Logger.warn("foo")
  end
end
