# Log

A `Logger` backend and frontend with enhanced filtering capabilities,
flexible configuration and utility macros.

## Usage

The package can be installed by adding `log` to your list of dependencies
in `mix.exs`:

```elixir
def deps do
  [
    {:log, ">= 0.3"}
  ]
end
```

Configure the `Logger` to use `Log.Backend` instead of `:console`

```elixir
config :logger,
  backends: [Log.Backend]
```

To use the backend it's sufficient to use `Logger`:

```elixir
require Logger
Logger.info("This is a message", tags: [:a_message])
```

`Log` provides an advanced frontend to `Logger` which adds new levels,
output filtering and other features that can be useful during development
and in production.
To access these features is necessary to use the module `Log` instead of
`Logger`:

```elixir
require Log
Log.info("This is a message", tags: [:a_message])
```

More advanced functionalities are explained in
[Advanced Usage](#advanced-usage) section.

### Advanced Usage

- Tagging
- `do` syntax
- `inspect`
- `@log_tags` attribute
- Custom Logger with pre-defined tags
- Available Log Levels
- `Log.Fields`

#### Tagging

The core feature of `Log` is to be able to tag messages and later on filter
messages not including some tags.

```elixir
Log.info("message 1", tags: [:tag1, :tag2])
Log.info("message 2", tag: :tag1)
```

With the environment variable `LOG_TAGS` it's possible to filter some
messages:

- `LOG_TAGS=tag2,tag1` displays both messages
- `LOG_TAGS=-tag2,tag1` displays only message 2
- `LOG_TAGS=-tag2` displays only message 2 (any message without tag2)
- `LOG_TAGS=-tag1` displays no messages
- `LOG_TAGS=tag3` displays no messages

The syntax for `LOG_TAGS` is explained in
[Output Filtering Configuration](#output-filtering-configuration)

#### Do Syntax

In addition to passing a string or a function as log message, to lazy
evaluate the content, it's also possible to use the `do` syntax to achieve
the same lazy-evaluation:

```elixir
require Log
Log.info(tags: [:a_tag, :another_tag]) do
  "This message #{interpolates} some variables"
end
```

#### Inspect

`IO.inspect` is a widely used function. `Log` provides a custom logger
named `Log.Inspect` which behaves like
[IO.inspect/2](https://hexdocs.pm/elixir/IO.html#inspect/2),
while preserving the ability to filter log messages:

```elixir
a = 1
b = Log.Inspect.info(a) + 2
# b is now 3
```

Like `inspect`, the return value of `Log.Inspect` is the data structure
passed. Log output is:

```
[2000-01-01T01:01:01.001Z] INFO:
1
```

The same options available for `IO.inspect` are available, such as `:label`:

```elixir
Log.Inspect.info(%{some: "data"}, label: "a message")
```

Which outputs:

```
[2000-01-01T01:01:01.001Z] INFO: a message
%{some: "data"}
```

Notice that differently from `IO.inspect`, `Log.Inspect` defaults `pretty` to
`true`.
The last feature of `Log.Inspect` is that it tags all the messages with the
tag `:inspect`, so removing inspect messages can be easily performed by
setting the environment variable `LOG_TAGS` to include `-inspect`.

#### Log Tags Attribute

When the attribute `@log_tags` is defined, any `Log` message will include
the tags specified in the attribute

```elixir
defmodule MyModule do
  require Log
  @log_tags [:tag1, :tag2]

  def hello do
    Log.info("message 1")
    Log.info("message 2")
  end

  @log_tags [:tag3]

  def world do
    Log.info("message 3")
  end

  def run do
    hello()
    world()
  end
end

MyModule.run()
```

Message 1 and 2 will be both tagged with `:tag1` and `:tag2`, while
message 3 will be tagged only with `:tag3`.

#### Custom Logger With Pre-Defined Tags

It's possible to create a Logger with some tags always added to every message
where the module is used:

```elixir
defmodule MyLog do
  use Log, tags: [:tag1, :tag2]
end
```

```elixir
defmodule MyModule do
  require Log

  @log_tags [:tag3]

  def run do
    Log.info("message")
  end
end

MyModule.run()
```

"message" will have tags: `:tag1`, `:tag2` and `:tag3`


#### Available Log Levels

If using `Log` frontend module instead of `Logger` directly, the following
levels are available:

- `trace`
- `debug`
- `info`
- `warn`
- `error`
- `fatal`

Otherwise the log levels are limited to the `Logger` levels:

- `debug`
- `info`
- `warn`
- `error`

#### Log.Fields

A common scenario is logging the entry point of a function, in such cases,
displaying the arguments of the function is important. The module
`Log.Fields` helps by formatting variables in a readable way:

```elixir
require Log.Fields
Log.Fields.info({"a message", %{some_id: 123, some_name: "Jon"}})
```

Will output:

```
[2000-01-01T01:01:01.001Z] INFO: a message (SomeId: 123, SomeName: Jon)
```

If `String` keys are used, no transformation to pascal case is performed.
It's possible to use a keyword instead of a map.

## Configuration

Replace `Logger` `:console` backend with `Log.Backend` in your configuration.

### Output Filtering Configuration

The environment variables are an interface to filter log output dinamically.
The available environment variables are the following:

- `CONSOLE_DEVICE` = `stdout | stderr` defaults to **stderr**
- `LOG_TAGS` = `_all | _untagged | tag_name | -tag_name | +tag_name`
  - `-` requires the tag to be missing
  - `+` requires the tag to be present
  - No sign means "One or more of no sign tags must be present"
- `LOG_LEVEL` =
  `_none | trace | debug | info | warn | error | fatal`
  - `_none` means no message will be logged
  - User defined levels are also supported in `LOG_LEVEL`
- `LOG_DEBUG` = `on | off` when set to **on** prints debug messages and
  errors, as well as tags information
- `LOG_FORMATTERS` = `on | off` when set to **on**, colorizes output
- `LOG_MODULE` = `on | off` when set to **on**, displays the module where
  log line is being invoked

### Timestamp Configuration

It is recommended, but not required, to set logging timestamp to UTC, to avoid
confusing issues with DST changes. This can be done in `config.exs` using:

```elixir
import Config

config :logger, utc_log: true
```

Or with the native `Logger` function:

```elixir
Logger.configure(utc_log: true)
```

The timestamp is always formatted according to ISO-8601 format, however no
timezone modifier is displayed except for UTC.
In case timestam is configured to use UTC, `Z` is appended to the timestamp.

### Additional configuration

Other configuration options are provided that can be set directly on the
`Logger` backend:

- Alias a module namespace
- Exclude some namespaces from writing output
- Change output color on a per-level basis

These options can be set either through `config.exs`

```elixir
import Config

config :logger, Log.Backend,
  module_alias: %{
    LogTest.Deeply.Nested.Module.WithLog => ""
  },
  exclude_namespaces: [],
  colors: %{}
```

Or with the native `Logger` function:

```elixir
Logger.configure_backend(
  Log.Backend,
  [
    module_alias: %{},
    exclude_namespaces: [],
    colors: %{}
  ]
)
```

#### Alias a Module Namespace

Given the modules:

- `A.Module.Namespace.For.Something`
- `Other.Module.Namespace.For.SomethingElse`

and the configuration:

```elixir
Logger.configure_backend(
  Log.Backend,
  [
    module_alias: %{
      A.Module.Namespace => "",
      Other.Module.Namespace => "OMN"
    }
  ]
)
```

When the log message "a message" is written from module
`A.Module.Namespace.For.Something` it will be displayed as:

```
[2000-01-01T01:01:01.001Z] For.Something INFO: a message
```

When the log message "a message" is written from module
`Other.Module.Namespace.For.SomethingElse` it will be displayed as:

```
[2000-01-01T01:01:01.001Z] OMN.For.SomethingElse INFO: a message
```

#### Exclude Namespaces

Given the modules:

- `A.Module.Namespace.For.Something`
- `A.Module.Namespace.For.SomethingElse`

and the configuration:

```elixir
Logger.configure_backend(
  Log.Backend,
  [
    exclude_namespaces: [
      A.Module.Namespace
    }
  ]
)
```

When the log message "a message" is written from module
`A.Module.Namespace.For.Something` or from
`A.Module.Namespace.For.SomethingElse`, no message is written.

#### Change Output Color

Given the following configuration:

```elixir
Logger.configure_backend(
  Log.Backend,
  [
    colors: %{
      debug: IO.ANSI.green(),
      error: [IO.ANSI.red(), IO.ANSI.bright()]
    }
  ]
)
```

- `error` color will is bold, red
- `debug` color is green

The `colors` map accepts level (as atoms) as keys, and
[IO.ANSI.ansidata](https://hexdocs.pm/elixir/IO.ANSI.html#t:ansidata/0) as
values.

## Customized Logger

It's possible to create a customized logger, which accepts a data structure
of your choice, as well as return a value of your choice.
It's sufficient to override the `bare_log` by following `Log.Fields`
footprint:

```elixir
defmodule UpLog do
  use Log, tags: [:upcase]

  @impl true
  def bare_log(data, meta)

  def bare_log(data, meta) when is_function(data) do
    Log.API.bare_log(
      fn ->
        data.() |> String.upcase()
      end,
      meta
    )
  end

  def bare_log(data, meta) do
    Log.API.bare_log(&String.upcase/1, meta)
  end
end
```

`UpLog` can be used like `Log`:

```elixir
require UpLog
UpLog.info("a message")
```

And will output the following message:

```
[2000-01-01T01:01:01.001Z] INFO: A MESSAGE
```

## TODO

- [ ] Guidelines for logging
- [ ] Testing
- [ ] Performance
