package Logging;

import BlueLib :: *;
import LogUnit :: *;

export LogUnit :: *;
export Logging :: *;

typedef enum {
	ERROR = 0,
	WARN = 1,
	INFO = 2,
	DEBUG = 3
} LogLevel deriving(Eq,Bits,FShow);

function ActionValue#(Bool) checkLogging(LogLevel level, LogUnit unit);
	return actionvalue
		let l <- getLogLevel(logUnitToString(unit));
		return pack(level) <= pack(l);
	endactionvalue;
endfunction

function DisplayColors getColor(LogLevel level);
	if (level == ERROR) return RED;
	else if (level == WARN) return YELLOW;
	else if (level == INFO) return GREEN;
	else return BLUE;
endfunction

function Action log(LogUnit unit, LogLevel level, Fmt text);
	action
		let test <- checkLogging(level, unit);
		if (test) printColorTimed(getColor(level), $format("[", fshow(level), fshow("]{"), logUnitToString(unit), fshow("} "), fshow(text)));
	endaction
endfunction

function ActionValue#(LogLevel) getLogLevel(String unit);
	return actionvalue
		let debug <- $test$plusargs("LOG_" + unit + "=DEBUG");
		let info <- $test$plusargs("LOG_" + unit + "=INFO");
		let warn <- $test$plusargs("LOG_" + unit + "=WARN");
		let error <- $test$plusargs("LOG_" + unit + "=ERROR");
		if (debug)
			return DEBUG;
		else if (info)
			return INFO;
		else if (warn)
			return WARN;
		else if (error)
			return ERROR;
		else begin
			let d <- getLogLevelDefault();
			return d;
		end
	endactionvalue;
endfunction

function ActionValue#(LogLevel) getLogLevelDefault();
	return actionvalue
		let debug <- $test$plusargs("LOG=DEBUG");
		let info <- $test$plusargs("LOG=INFO");
		let warn <- $test$plusargs("LOG=WARN");
		if (debug)
			return DEBUG;
		else if (info)
			return INFO;
		else if (warn)
			return WARN;
		else
			return ERROR;
	endactionvalue;
endfunction

endpackage