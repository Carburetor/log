defmodule Log.IO do
  @callback write(device :: IO.device(), output :: IO.chardata() | String.Chars.t()) ::
              no_return()
end
