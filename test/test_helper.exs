Logger.configure(utc_log: true)

Logger.remove_backend(:console)
Logger.add_backend(Log.Backend.Sync)

Logger.configure_backend(Log.Backend.Sync,
  module_alias: %{
    LogTest.Deeply.Nested.Module.WithLog => ""
  }
  # colors: %{
  #   error: IO.ANSI.blue()
  # }
)

ExUnit.start()
