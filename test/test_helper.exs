Logger.configure(utc_log: true)

Logger.remove_backend(:console)
Logger.add_backend(Log.Backend)

Logger.configure_backend(
  Log.Backend,
  []
  # module_alias: %{
  #   LogTest.Deeply.Nested.Module.WithLog => ""
  # }
  # exclude_namespaces: [
  #   LogTest.Deeply
  # ]
  # colors: %{
  #   error: IO.ANSI.blue()
  # }
)

ExUnit.start()
