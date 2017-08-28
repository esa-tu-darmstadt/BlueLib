package PacketParser;

import BlueLibTests :: *;
import GetPut :: *;
import FIFO :: *;
import Vector :: *;

import AXI4_Stream :: *;

interface PktParser#(type streamWidth, type pktType);
    interface Put#(AXI4_Stream_Pkg#(streamWidth, 0)) pktStream;
    method Action resetProcessing();
    interface Get#(Bit#(streamWidth)) sideband;
    interface Get#(Tuple2#(Bit#(streamWidth), Bool)) sidebandIsLast;
endinterface

typedef enum {
    PARSE,
    DROP,
    OUTPUT
    } ParserStatus deriving(Bits, Eq, FShow);

typedef struct {
    function ActionValue#(ParserStatus) _(pktType pkt) fun;
    function Bool _() predicate;
} ParseFunction#(type pktType);

instance Eq#(ParseFunction#(pktType));
    function Bool \== (ParseFunction#(pktType) x, ParseFunction#(pktType) y);
        return False;
    endfunction

    function Bool \/= (ParseFunction#(pktType) x, ParseFunction#(pktType) y);
        return !(x == y);
    endfunction
endinstance

typedef union tagged {
    ParseFunction#(pktType) FunctionSimple;
    List#(ParseFunction#(pktType)) FunctionList;
    } PktParserFun#(type pktType) deriving(Eq);

typedef struct {
    Integer stage;
    PktParserFun#(pktType) fun;
} PktParserStages#(type pktType) deriving(Eq);

module mkPktParser#(List#(PktParserStages#(pktType)) parserStages)(PktParser#(streamWidth, pktType))
    provisos(
        Bits#(pktType, pktType_sz),
        Mul#(streamWidth, wordsInPkt, pktType_sz)
        );

    FIFO#(AXI4_Stream_Pkg#(streamWidth, 0)) pktsIn <- mkFIFO();

    FIFO#(Tuple2#(Bit#(streamWidth), Bool)) outputFIFO <- mkFIFO();

    Reg#(UInt#(TLog#(wordsInPkt))) parsePkt <- mkReg(0);

    Reg#(ParserStatus) status <- mkReg(PARSE);
    Reg#(pktType) currentPkt <- mkReg(unpack(0));

    function Action doParsePkt(Maybe#(ParseFunction#(pktType)) fun);
        action
            Vector#(wordsInPkt, Bit#(streamWidth)) pktTmpVec = unpack(pack(currentPkt));
            pktTmpVec[parsePkt] = pktsIn.first().data;
            pktsIn.deq();

            pktType pktTmp = unpack(pack(pktTmpVec));
            let newStatus = status;
            if(isValid(fun))
                newStatus <- fun.Valid.fun(pktTmp);
            currentPkt <= pktTmp;

            if(pktsIn.first().last()) begin
                status <= PARSE;
                parsePkt <= 0;
            end else begin
                status <= newStatus;
                parsePkt <= parsePkt + 1;
            end
        endaction
    endfunction

    Rules processRules = emptyRules();
    Wire#(Bool) isHandled <- mkDWire(False);
    for(List#(PktParserStages#(pktType)) stage = parserStages; stage != Nil; stage = List::tail(stage)) begin
        if(List::head(stage).fun matches tagged FunctionSimple .x) begin
        processRules = rJoinMutuallyExclusive(rules
            rule parse if(status == PARSE && x.predicate && fromInteger(List::head(stage).stage) == parsePkt);
                doParsePkt(tagged Valid x);
                isHandled <= True;
            endrule

            (* preempts="parse, isHandledSet" *)
            rule isHandledSet if(status == PARSE && x.predicate && fromInteger(List::head(stage).stage) == parsePkt);
                isHandled <= True;
                doParsePkt(tagged Invalid);
                printColorTimed(RED, $format("Stage %d blocks.", fromInteger(List::head(stage).stage)));
                $finish();
            endrule
        endrules, processRules);
        end else if(List::head(stage).fun matches tagged FunctionList .x) begin
            for(List#(ParseFunction#(pktType)) list = x; list != Nil; list = List::tail(list)) begin
            processRules = rJoinMutuallyExclusive(rules
                rule parse if(status == PARSE && List::head(list).predicate && fromInteger(List::head(stage).stage) == parsePkt);
                    doParsePkt(tagged Valid List::head(list));
                    isHandled <= True;
                endrule

                (* preempts = "parse, isHandledSet" *)
                rule isHandledSet if(status == PARSE && List::head(list).predicate && fromInteger(List::head(stage).stage) == parsePkt);
                    isHandled <= True;
                    doParsePkt(tagged Invalid);
                    printColorTimed(RED, $format("Stage %d blocks.", fromInteger(List::head(stage).stage)));
                    $finish();
                endrule
            endrules, processRules);
            end
        end
    end
    addRules(processRules);

    rule dontCare if(status == PARSE && !isHandled);
        //$display("Don't care to handle in stage %d", parsePkt);
        doParsePkt(tagged Invalid);
    endrule

    rule drop if(status == DROP);
        if(pktsIn.first().last)
            status <= PARSE;

        parsePkt <= 0;
        pktsIn.deq();
    endrule

    rule forwardSideband if(status == OUTPUT);
        if(pktsIn.first().last)
            status <= PARSE;
        outputFIFO.enq(tuple2(pktsIn.first().data, pktsIn.first().last));
        pktsIn.deq();
    endrule

    (* preempts="forwardSideband, sidebandBlocks" *)
    rule sidebandBlocks if(status == OUTPUT);
        pktsIn.deq();
        printColorTimed(RED, $format("Sideband blocks."));
        $finish();
    endrule

    method Action resetProcessing();
        status <= PARSE;
        parsePkt <= 0;
    endmethod

    interface pktStream = toPut(pktsIn);

    interface Get sideband;
        method ActionValue#(Bit#(streamWidth)) get();
            match {.v, .last} = outputFIFO.first(); outputFIFO.deq();
            return v;
        endmethod
    endinterface
    interface sidebandIsLast = toGet(outputFIFO);
endmodule

endpackage