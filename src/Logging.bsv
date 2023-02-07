package Logging;

import OInt :: *;
import Vector :: *;
import BuildVector :: *;

import BlueLibTests :: *;
import Assertions :: *;


typedef enum {
    L_WARNING,
    L_ERROR,
    L_TB_NORMAL,
    L_TB_BLUE,
    L_TB_YELLOW,
    L_TB_GREEN
} LoggingLevel deriving (Bits, Eq, FShow);

Bool verbose = False;
typedef 6 N_LOG_TYPES;

// Returns a one-hot-encoded LoggingLevel Bit vector
function Bit#(N_LOG_TYPES) oneHotLog(LoggingLevel level);
    return pack(toOInt(pack(level))); 
endfunction

function Action debug(LoggingLevel log, Fmt message);
    action
        `ifdef FLAG_LOG_TYPES
        let v_log_config = vec(`FLAG_LOG_TYPES);
        `else 
        let v_log_config = vec(L_WARNING, L_ERROR);
        `endif
        let log_config_1hot = map(oneHotLog, v_log_config);
        // Bit vector encoding the state of log config
        Bit#(N_LOG_TYPES) log_config = fold(\| , log_config_1hot);

        if( (unpack(pack(toOInt(pack(log)))) & log_config) > 0 || verbose) begin
            DisplayColors color = ?;
            if (log == L_WARNING || log == L_TB_YELLOW)
                color = YELLOW;
            else if (log == L_ERROR)
                color = RED;
            else if (log == L_TB_NORMAL)
                color = NORMAL;
            else if (log == L_TB_GREEN)
                color = GREEN;
            else
                color = BLUE;
            
            if (log != L_ERROR)
                printColor(color, fshow(log) + $format(": ") + fshow(message));
            else (log == L_ERROR)
                assertTrue(False, fshow(message));
        end
    endaction
endfunction

endpackage