Logger.configure(
  level: :debug,
  utc_log: true
)

Logger.remove_backend(:console)
Logger.add_backend(Log.Backend.Sync)

ExUnit.start()
