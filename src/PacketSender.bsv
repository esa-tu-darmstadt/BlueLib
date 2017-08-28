package PacketSender;

import GetPut :: *;
import FIFO :: *;
import Vector :: *;
import ClientServer :: *;

import AXI4_Stream :: *;

module mkVecSend(Server#(Vector#(a, b), AXI4_Stream_Pkg#(b_sz, user)))
    provisos(Bits#(b, b_sz),
             Add#(1, a, a_p1),
             Log#(a_p1, a_addr),
             Mul#(b_sz, a, total_bits),
             Mul#(8, total_bytes, total_bits),
             Max#(total_bytes, 64, used_bytes),
             Mul#(used_bytes, 8, used_bits),
             Mul#(b_sz, used_words, used_bits),
             Add#(used_words, 1, used_words_p1),
             Log#(used_words_p1, used_words_addr)

        );

    Reg#(Vector#(a, b)) readBufferReg[2] <- mkCReg(2, replicate(unpack(0)));

    UInt#(used_words_addr) totalWords = fromInteger(valueOf(used_words));
    Reg#(UInt#(used_words_addr)) wordCntr[2] <- mkCReg(2, totalWords);

    messageM(" " + integerToString(valueOf(used_words_addr)) + " " + integerToString(valueOf(used_words)) + " " + integerToString(valueOf(used_bytes)));

    interface Put request;
        method Action put(Vector#(a, b) in) if(wordCntr[1] == totalWords);
            readBufferReg[1] <= in;
            wordCntr[1] <= 0;
        endmethod
    endinterface

    interface Get response;
        method ActionValue#(AXI4_Stream_Pkg#(b_sz, user)) get() if(wordCntr[0] != totalWords);
            let data = 0;
            if(wordCntr[0] < fromInteger(valueOf(a))) begin
                data = pack(readBufferReg[0][wordCntr[0]]);
            end
            let pkg = AXI4_Stream_Pkg {data: data, keep: 'hff, last: wordCntr[0] == (totalWords - 1), user: 0, dest: 0};
            wordCntr[0] <= wordCntr[0] + 1;
            return pkg;
        endmethod
    endinterface
endmodule

endpackage
