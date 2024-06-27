# Logging

This provides a function `log(...)` which allows to display log messages in a simulation (both BlueSim and Verilog).
All Log messages have a *level* and. Runtime parameters define log messages of which level are displayed, either for a module, all modules in a package or globally.

## Limitations

The `log` function does not work well with in not directly synthesized modules: The module and package name, which are used to determine whether to display the message, are always taken from module being synthesized (and not from the module where the function is used).
When this presents an alternative based on "Logger Modules" is available. For Details see [below](#Alternative).

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
make LOG="GLOBAL=WARN MyPackage=INFO myModule=DEBUG"
```

## Disable

Logging can be completely disabled via `make NOLOG=1`, this will remove all Logging-related stuff from the generated verilog.
This is recommended when building for hardware, as otherwise the output of the Synthesis tool will be cluttered with messages.

## Alternative

With this alternative approach it is possible to explicitly specify the string being used to determine whether a log message should be displayed (the "log unit").
This is specified by instantiating a module `mkLogger(String)` which provides a single method `log(LogLevel,Fmt)` (the method has the same parameters as the `log` function detailed above).

Example:
```
Logger log <- mkLogger("MyLogger");
```

Specifying at runtime which messages should be displayed works similarly as before (see [Runtime](#Runtime)), but instead of the module or package name you need to use the string given to your logger module.

Example:
```
make LOG="GLOBAL=WARN MyLogger=DEBUG"
```

Note: The `GLOBAL` option also works here.
It is also possible to freely combine both approaches.