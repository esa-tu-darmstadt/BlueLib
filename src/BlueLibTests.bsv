package BlueLibTests;

interface TestHandler;
    method Action go();
    method Bool done();
endinterface

typedef enum {
    BLUE,
    RED,
    YELLOW,
    GREEN,
    MAGENTA,
    CYAN,
    WHITE,
    ORANGE,
    PURPLE,
    NORMAL
    } DisplayColors deriving(Bits, Eq, FShow);

function Action printColor(DisplayColors color, Fmt text);
    action
        `ifndef NOCOLOR
            Fmt colorFmt = ?;
            case(color)
                BLUE: colorFmt = $format("%c[34m",27);
                RED: colorFmt = $format("%c[31m",27);
                YELLOW: colorFmt = $format("%c[33m",27);
                GREEN: colorFmt = $format("%c[32m",27);
                MAGENTA: colorFmt = $format("%c[35m",27);
                CYAN: colorFmt = $format("%c[36m",27);
                WHITE: colorFmt = $format("%c[37m",27);
                // 256-color codes - not part of the base 8 ANSI colors
                ORANGE: colorFmt = $format("%c[38;5;208m",27);
                PURPLE: colorFmt = $format("%c[38;5;129m",27);
                NORMAL: colorFmt = $format("");
            endcase
            $display(colorFmt + text + $format("%c[0m",27));
        `else
            $display(text);
        `endif
    endaction
endfunction

function Action printColorTimed(DisplayColors color, Fmt text);
    action
        let s <- $time;
        printColor(color, $format("(%0d) ", s) + text);
    endaction
endfunction

endpackage