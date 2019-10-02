Logger.configure(utc_log: true)

Logger.remove_backend(:console)
Logger.add_backend(Log.Backend.Sync)

# Logger.configure_backend(Log.Backend.Sync,
#   colors: %{
#     debug: IO.ANSI.green()
#   }
# )

ExUnit.start()
