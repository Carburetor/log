defmodule Log.Device do
  @moduledoc """
  Parser for `CONSOLE_DEVICE` environment variable
  """

  @type t :: :standard_error | :standard_io

  @spec parse(device :: String.t()) :: t() | :error
  def parse(device)
  def parse("stdout"), do: :standard_io
  def parse("stderr"), do: :standard_error
  def parse(_), do: :error

  @spec parse!(device :: String.t()) :: t() | no_return()
  def parse!(device) do
    case parse(device) do
      :error -> raise(ArgumentError, "Log device invalid: #{device}")
      result -> result
    end
  end
end
