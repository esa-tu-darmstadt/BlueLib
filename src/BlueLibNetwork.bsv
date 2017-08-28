package BlueLibNetwork;

import Vector :: *;

function a toggleEndianess(a v)
    provisos(Bits#(a, a_sz)
            ,Mul#(8, bytes, a_sz)
    );

    Vector#(bytes, Bit#(8)) in = unpack(pack(v));
    return unpack(pack(reverse(in)));
endfunction

function Vector#(a, b) toggleEndianessVec(Vector#(a, b) v)
    provisos(Bits#(b, b_sz),
             Mul#(8, a__, b_sz));
    return map(toggleEndianess, v);
endfunction

endpackage