# Logging

This provides a function `log(...)` which allows to display log messages in a simulation (both BlueSim and Verilog).
All Log messages have a *level* and. Runtime parameters define log messages of which level are displayed, either for a module, all modules in a package or globally.

## Usage

The package `Logging` has to be imported where logging should be used.
Afterwards just call this method: `function Action log(LogLevel level, Fmt text)`.

`LogLevel` is one of `ERROR`,`WARN`,`INFO`,`DEBUG`.
`Fmt` is the standard type from the Bluespec library, created e.g. by `$format`.

Example:
```
log(INFO, $format("My log message %x", value));
```
Example Message:
```
(100) [INFO]{myModule} My log message: 10
// (timestamp) [level]{module} message
// different colors are used based on the level
```

## Runtime

By default only `ERROR` messages are shown. To change this, you can add parameters to the `make` call:
 - To change the global log level use `LOG="GLOBAL=level"`
 - To change the log level of a module or package, use the name of the module or package instead of "GLOBAL": `LOG="myModule=level"`
 - You can combine multiple log level definitions separated by whitespaces: `LOG="GLOBAL=level myModule=level`. In this case the log level for a module takes precedence over the level of the package, which takes precedence over the global level.

Example:
```
make LOG="GLOBAL_WARN MyPackage=INFO myModule=DEBUG"
```
