package Logging;

import BlueLib :: *;

interface Logger;
	method Action log(LogLevel level, Fmt txt);
endinterface

module mkLogger#(String unit)(Logger);
	method Action log(LogLevel level, Fmt txt);
		sendMessage(unit, unit, level, txt);
	endmethod
endmodule

typedef enum {
	ERROR = 0,
	WARN = 1,
	INFO = 2,
	DEBUG = 3
} LogLevel deriving(Eq,Bits,FShow);

function ActionValue#(Bool) checkLogging(String moduleName, String packageName, LogLevel level);
	return actionvalue
		let l <- getLevel(moduleName, packageName);
		return pack(level) <= pack(l);
	endactionvalue;
endfunction

function DisplayColors getColor(LogLevel level);
	if (level == ERROR) return RED;
	else if (level == WARN) return YELLOW;
	else if (level == INFO) return GREEN;
	else return NORMAL;
endfunction

function Action log(LogLevel level, Fmt text);
	action
		sendMessage(genModuleName(), genPackageName(), level, text);
	endaction
endfunction

function Action sendMessage(String moduleName, String packageName, LogLevel level, Fmt text);
	action
		`ifndef NOLOG
			let test <- checkLogging(moduleName, packageName, level);
			if (test) printColorTimed(getColor(level), $format("[", fshow(level), fshow("]{"), moduleName, fshow("} "), fshow(text)));
		`endif
	endaction
endfunction

function ActionValue#(LogLevel) getLevel(String moduleName, String packageName);
	return actionvalue
		let global <- getLogLevelDefault;
		let file <- getLogLevel(packageName, global);
		let unit <- getLogLevel(moduleName, file);
		return unit;
	endactionvalue;
endfunction

function ActionValue#(LogLevel) getLogLevel(String unit, LogLevel defaultValue);
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
			return defaultValue;
		end
	endactionvalue;
endfunction

function ActionValue#(LogLevel) getLogLevelDefault();
	return actionvalue
		let debug <- $test$plusargs("LOG_GLOBAL=DEBUG");
		let info <- $test$plusargs("LOG_GLOBAL=INFO");
		let warn <- $test$plusargs("LOG_GLOBAL=WARN");
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