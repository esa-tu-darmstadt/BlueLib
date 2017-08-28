package BlueLibFIFO;

import BlueLibTests :: *;
import FIFOLevel :: *;

module mkMaxOutFIFO#(Fmt name)(FIFOCountIfc#(t, max))
    provisos(Bits#(t, width_element ),
    Log#(TAdd#(max,1),cntSize));

    FIFOCountIfc#(t, max) f <- mkFIFOCount();

    Reg#(UInt#(cntSize)) maxCounter <- mkReg(0);

    rule newMax if(maxCounter < f.count());
        printColorTimed(RED, $format(name, " -> %d", f.count()));
        maxCounter <= f.count();
    endrule

    return f;
endmodule

endpackage