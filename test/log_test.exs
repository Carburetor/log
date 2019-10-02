defmodule LogTest do
  use ExUnit.Case
  require Logger

  test "foo" do
    Logger.error("foo")
  end
end
