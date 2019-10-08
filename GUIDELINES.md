# Logging Guidelines

All log entries should be tagged.

All log entries outputting messages which include some data should be tagged
with `:data`. For example, input data of a function (arguments) should have
the `:data` tag applied, as well as the output data of a function (return
value).

## Choosing the Log Level

When trying to choose which log level should be used for a message, refer
to this guide:

### Trace Level

The `trace` level is used to log the entry of a function that concludes with
either an `info` or `debug` log message.

Log messages at the `trace` level are typically worded to indicate that
something is being done or about to be done. The ing present or gerund form
of verbs is used in `trace` messages, for example "Writing message".

### Debug Level

The `debug` level is used to log the completion of a secondary operation of
a function, or for recording other details.

Log messages at the `debug` level are typically worded to indicate that
something has been done or completed. The ed past tense form of verbs is
used in debug messages, for example "Wrote initial message".

### Info Level

The `info` level is used to log the completion of the principle operation of
a function.

Log messages at the `info` level are typically worded to indicate that
something has been done or completed. The ed past tense form of verbs is
used in `info` messages, for example "Wrote message".

### Warn Level

The `warn` level is used to log an unexpected condition that isn't an error
and that does not need to terminate the process. A warn log message
indicates something that may not have been intentional and that a developer
or operator should examine.

### Error Level

The `error` level is used to log an error message immediately before an
error is raised or when handling an error tuple.

### Fatal Level

The `fatal` level is used only when a service (for example: a `GenServer`)
is terminating due to an error.
