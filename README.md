# Log

- `CONSOLE_DEVICE` = `stdout | stderr`
- `LOG_TAGS` = `_all | _untagged | tag_name | -tag_name | +tag_name`
  - `-` requires the tag to be missing
  - `+` requires the tag to be present
  - No sign means "One or more of no sign tags must be present"
- `LOG_LEVEL` = `_none | debug | info | warn | error | user_defined_level`
- `LOG_DEBUG` = `on | off` on prints debug messages
- `LOG_FORMATTERS` = `on | off` on colorize output
- `LOG_MODULE` = `on | off` on shows module where log line is being invoked

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `log` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:log, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/log](https://hexdocs.pm/log).
