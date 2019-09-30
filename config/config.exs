import Config

config :logger,
  backends: [Log.Backend.Sync],
  level: :debug,
  utc_log: true,
  compile_time_purge_matching: [
    [level_lower_than: :debug]
  ]
