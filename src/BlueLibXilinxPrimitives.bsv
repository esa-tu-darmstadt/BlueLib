package BlueLibXilinxPrimitives;

import Clocks::*;
import Vector::*;
import BRAM::*;
import GetPut::*;
import ClientServer::*;
import List::*;

// Provides:
// mkDNA_PORTE2
// mkXilinxDNA (higher level wraper for mkDNA_PORTE2)
// mkICAPE3
// mkICAPE2

/* Xilinx DNA_PORTE2 primitive */
(* always_ready, always_enabled *)
interface DNA_PORTE2_Ifc;
    method Bit#(1)  _read;            // 1-bit output: DNA output data
    method Action _write(Bit#(1) i);  // 1-bit input: User data input pin
    method Action rd(Bit#(1) i);      // Active-High load DNA, active-Low read input
    method Action shift(Bit#(1) i);   // Active-High shift enable input
endinterface

import "BVI" DNA_PORTE2 =
module vMkDNA_PORTE2(DNA_PORTE2_Ifc);
    default_clock clk(CLK);
    default_reset no_reset;

    parameter SIM_DNA_VALUE = 96'hDEADBEEF_DEADBEEF_DEADBEEF; // 96-bit value for simulation

    method DOUT _read();
    method      _write(DIN) enable((*inhigh*)en0);
    method      rd(READ) enable((*inhigh*)en1);
    method      shift(SHIFT) enable((*inhigh*)en2);

    schedule (shift) CF (rd, _write);
    schedule (_write) CF (rd, shift);
    schedule (rd) CF (_write, shift);

    schedule (_read) CF (_write, shift, rd);
endmodule

module mkDNA_PORTE2(DNA_PORTE2_Ifc);
	let _m <- vMkDNA_PORTE2;
	return _m;
endmodule

/* Bluespec higher level logic */
interface XilinxDNA#(numeric type reg_stages);
    method Bit#(96) _read;
endinterface

module mkXilinxDNA(XilinxDNA#(reg_stages));
    // DNA_PORTE2 on Ultrascale+ allows 175 or 200 MHz max (see ds923), so let's drive at half the design clock
    // Observe: DNA_PORT on Virtex-7 has a maximum of 100 MHz (see ds183)
    let default_clk <- exposeCurrentClock;
    let slow_clk <- mkClockDivider(2);
    let slow_reset <- mkReset(2, True, slow_clk.slowClock);

    Reg#(UInt#(8)) count <- mkReg(0, clocked_by slow_clk.slowClock, reset_by slow_reset.new_rst);
    Reg#(Bit#(96)) dna_val <- mkRegU(clocked_by slow_clk.slowClock, reset_by slow_reset.new_rst);
    Reg#(Bit#(97)) dna_val_reg <- mkRegU(clocked_by slow_clk.slowClock, reset_by slow_reset.new_rst);
    ReadOnly#(Bit#(97)) dna_val_nullwire <- mkNullCrossingWire(default_clk, dna_val_reg);
    Vector#(reg_stages, Reg#(Bit#(97))) stages <- replicateM(mkRegU);

    let dna <- mkDNA_PORTE2(clocked_by slow_clk.slowClock, reset_by slow_reset.new_rst);

    rule preload if(count < 1);
        dna.rd(1);
        dna.shift(1);
        count <= count + 1;
    endrule

    rule getData if(count < 97);
        dna.rd(0);
        dna.shift(1); // TODO do not enable shiftout for last bit
        dna_val <= {dna, dna_val[95:1]}; // shift value into register
        count <= count + 1;
    endrule

    // make bluespec scheduler happy
    (* descending_urgency = "preload, getData, dna_idle" *)
    rule dna_idle;
        dna.rd(0);
        dna.shift(0);
    endrule

    // don't have any input for now
    rule dna_input;
        dna <= 0;
    endrule

    rule cc_crossing;
        dna_val_reg <= {pack(count==97), dna_val};
    endrule

    rule reg_chain;
        for (Integer i = 0; i < valueOf(reg_stages); i = i + 1) begin
            if (i == 0) begin
                stages[0] <= dna_val_nullwire;
            end else begin
                stages[i] <= stages[i-1];
            end
        end
    endrule

    method Bit#(96) _read if(stages[valueOf(reg_stages)-1][96] == 1);
        return stages[valueOf(reg_stages)-1][95:0];
    endmethod
endmodule

(* always_ready, always_enabled *)
interface ICAPE2_Ifc;
	method Bit#(32)  _read;            // 32-bit output: Configuration data output bus
	method Action _write(Bit#(32) i);  // 32-bit input: Configuration data input bus
	method Action rdwrb(Bit#(1) i);    // 1-bit input: Read/Write Select input
	method Action csib(Bit#(1) i);     // 1-bit input: Active-Low ICAP Enable
endinterface

import "BVI" ICAPE2 =
module vMkICAPE2(ICAPE2_Ifc);
	default_clock clk(CLK);
	default_reset no_reset;

	parameter ICAP_WIDTH = "X32";

	method O _read();
	method   _write(I) enable((*inhigh*)en0);
	method   rdwrb(RDWRB) enable((*inhigh*)en1);
	method   csib(CSIB) enable((*inhigh*)en2);

	schedule (_read) CF (_write);
	schedule (csib) CF (rdwrb);
	schedule (_write) CF (csib, rdwrb);
endmodule

module mkICAPE2(ICAPE2_Ifc);
	let _m <- vMkICAPE2;
	return _m;
endmodule

(* always_ready, always_enabled *)
interface ICAPE3_Ifc;
	method Bit#(32)  _read;            // 32-bit output: Configuration data output bus
	method Action _write(Bit#(32) i);  // 32-bit input: Configuration data input bus
	method Action rdwrb(Bit#(1) i);    // 1-bit input: Read/Write Select input
	method Action csib(Bit#(1) i);     // 1-bit input: Active-Low ICAP Enable
	// output prdone
	// output prerror
	// output avail
endinterface

import "BVI" ICAPE3 =
module vMkICAPE3(ICAPE3_Ifc);
	default_clock clk(CLK);
	default_reset no_reset;

	// parameter ICAP_AUTO_SWITCH

	method O _read();
	method   _write(I) enable((*inhigh*)en0);
	method   rdwrb(RDWRB) enable((*inhigh*)en1);
	method   csib(CSIB) enable((*inhigh*)en2);

	schedule (_read) CF (_write);
	schedule (csib) CF (rdwrb);
	schedule (_write) CF (csib, rdwrb);
endmodule

module mkICAPE3(ICAPE3_Ifc);
	let _m <- vMkICAPE3;
	return _m;
endmodule

// Xilinx Parametrizable Macros for memory
typedef enum {AUTO, BRAM, URAM, DISTRIBUTED, MIXED} XilinxMemoryPrimitive deriving (Bits, Eq, Bounded);

instance DefaultValue#(XilinxMemoryPrimitive);
    defaultValue = AUTO;
endinstance

function String xilinxMemPrimitiveToString(XilinxMemoryPrimitive x);
    case (x)
        AUTO:         return "auto";
        BRAM:         return "block";
        URAM:         return "ultra";
        DISTRIBUTED:  return "distributed";
        MIXED:        return "mixed";
    endcase
endfunction

typedef union tagged {
    void   None;
    String File;
} MemoryInitFile deriving (Eq);

instance DefaultValue#(MemoryInitFile);
    defaultValue = tagged None;
endinstance

typedef struct {
    XilinxMemoryPrimitive memType;
    Integer               memSizeWords;
    Integer               readLatency;
    MemoryInitFile        memoryInitFile;
} XPMMemConfig;


(* always_ready, always_enabled *)
interface XPM_SPRAM_Ifc#(numeric type addr_w, numeric type data_w);
    method Action addra(Bit#(addr_w) addr);
    method Action dina(Bit#(data_w) data);
    method Bit#(data_w) douta();
endinterface

import "BVI" xpm_memory_spram =
module vMkXPMSPRAM#(XPMMemConfig cfg)(XPM_SPRAM_Ifc#(addr_w, data_w));
    // Create an active high reset signal
    ReadOnly#(Bool) resetPositive <- isResetAsserted;
    port rsta = resetPositive;
    no_reset; // do not use implicity reset

    // Set clock port name
    default_clock clk(clka);

    parameter ADDR_WIDTH_A = valueOf(addr_w);
    parameter BYTE_WRITE_WIDTH_A = valueOf(data_w); // Set to data_w for word-enabld writes or 8 for byte enabled writes
    parameter MEMORY_PRIMITIVE = xilinxMemPrimitiveToString(cfg.memType);
    parameter MEMORY_SIZE = cfg.memSizeWords;
    parameter READ_DATA_WIDTH_A = valueOf(data_w);
    parameter READ_LATENCY_A = cfg.readLatency;
    parameter READ_RESET_VALUE_A = "0";
    parameter WRITE_DATA_WIDTH_A = valueOf(data_w);
    parameter MEMORY_INIT_PARAM = "";
    parameter MEMORY_INIT_FILE = case (cfg.memoryInitFile) matches
                                    tagged None: "none";
                                    tagged File .filename: filename;
                                endcase;

    // Permanently disable sleep and enable output register
    port sleep = 1'b0;
    port regcea = 1'b1;

    // Set address and enable
    method addra(addra) enable (ena);
    // Set data in and write enable
    method dina(dina) enable (wea);
    // Get output data (always ready)
    method douta douta();

    schedule (addra) SB (dina);
    schedule (douta) CF (addra, dina);
endmodule


module mkSPRAM#(XPMMemConfig memconfig)(BRAMServer#(Bit#(addr_w), Bit#(data_w)));

    XPM_SPRAM_Ifc#(addr_w, data_w) ram <- vMkXPMSPRAM(memconfig);

    // Track read requests to return data after the appropriate latency
    List#(Reg#(Bool)) request_legal <- List::replicateM(memconfig.readLatency, mkRegU);
    Wire#(Bool) read_request <- mkDWire(False);

    (* no_implicit_conditions *)
    rule propagate_request_legal;
        for (Integer i = memconfig.readLatency - 1; i > 0; i = i - 1) begin
            request_legal[i] <= request_legal[i - 1];
        end
        request_legal[0] <= read_request;
    endrule

    
    interface Get response;
        method ActionValue#(Bit#(data_w)) get() if (request_legal[memconfig.readLatency - 1]);
            return ram.douta();
        endmethod
    endinterface

    interface Put request;
        method Action put(BRAMRequest#(Bit#(addr_w), Bit#(data_w)) rq);
            ram.addra(rq.address);
            if (rq.write) begin
                ram.dina(rq.datain);
            end else begin
                read_request <= True;
            end
        endmethod
    endinterface
endmodule

endpackage
