package Assertions;
    import BlueLibTests::*;

    import "BDPI" function Action bad_exit(Int#(32) code); // Wrapper for C exit function to make assertions CI-capable

    function Action assertEquals(t expected, t actual, Fmt additional_info)
        provisos (Bits#(t, sz_t), Eq#(t), FShow#(t));
        action
            if(expected != actual) begin
                printColorTimed(RED, $format("Assertion failed: ") + additional_info + $format("\nExpected: ") + fshow(expected) + $format(", got ") + fshow(actual));
                bad_exit(-1);
            end
        endaction
    endfunction

    function Action assertTrue(Bool exp, Fmt additional_info);
        action
            if(!exp) begin
                printColorTimed(RED, $format("Assertion failed: ") + additional_info);
                bad_exit(-1);
            end
        endaction
    endfunction

    function Action assertFalse(Bool exp, Fmt additional_info);
        action
            if(exp) begin
                printColorTimed(RED, $format("Assertion failed: ") + additional_info);
                bad_exit(-1);
            end
        endaction
    endfunction
endpackage : Assertions