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
    NORMAL
    } DisplayColors deriving(Bits, Eq, FShow);

function Action printColor(DisplayColors color, Fmt text);
    action
        Fmt colorFmt = ?;
        case(color)
            BLUE: colorFmt = $format("%c[34m",27);
            RED: colorFmt = $format("%c[31m",27);
            YELLOW: colorFmt = $format("%c[33m",27);
            GREEN: colorFmt = $format("%c[32m",27);
            NORMAL: colorFmt = $format("");
        endcase
        $display(colorFmt + text + $format("%c[0m",27));
    endaction
endfunction

function Action printColorTimed(DisplayColors color, Fmt text);
    action
        let s <- $time;
        printColor(color, $format("(%0d) ", s) + text);
    endaction
endfunction

endpackage