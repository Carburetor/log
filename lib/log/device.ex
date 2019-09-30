defmodule Log.Device do
  @spec get(device :: String.t()) :: :standard_error | :standard_io
  def get(device)

  def get("stdout"), do: :standard_io
  def get("stderr"), do: :standard_error

  def get(device) do
    raise(ArgumentError, message: "Log device invalid: #{device}")
  end
end
