# Logging

This provides a function `log(...)` which allows to display log messages in a simulation (both BlueSim and Verilog).
Log messages have a *level* and a *unit* (user-defined). Runtime parameters define log messages of which level are displayed, either for individual units or globally.

## Preparation

Before using this, some files have to be created for the user-defined *units*. This is done by calling the script `createLogLevels.sh` with the required units as arguments. All units must be upper-case (the script will convert them accordingly).

Example:
```
./createLogLevels.sh TESTBENCH UNITA UNITB
``` 

## Usage

First, the package `Logging` has to be imported where logging should be used.
Afterwards just call this method: `function Action log(LogUnit unit, LogLevel level, Fmt text)`.

`LogUnit` is one of the arguments to the script.
`LogLevel` is one of `ERROR`,`WARN`,`INFO`,`DEBUG`.
`Fmt` is the standard type from the Bluespec library, created e.g. by `$format`.

Example:
```
log(TESTBENCH, INFO, $format("My log message %x", value));
```
Example Message:
```
(100) [INFO]{TESTBENCH} My log message: 10
// (timestamp) [level]{unit} message
// different colors are used based on the level
```

## Runtime

By default only `ERROR` messages are shown. To change this, you can add parameters to the `make` call:
You can set the global level via `LOG=level` and the level per unit via `LOG_unit=level`. If defined, the level per unit takes precedence, the global level is used where no per-unit level is defined.

Example:
```
make LOG=INFO LOG_UNITA=DEBUG
```
