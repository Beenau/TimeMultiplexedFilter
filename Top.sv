`timescale 1ns / 1ps

module Top#(parameter N = 3,
                      WII = 2, WFI = 6,
                      WIO = 2, WFO = 6)
       (input CLK, RST,
        output [WIO+WFO-1:0] y);
       
       reg [WII+WFI-1:0] x1, x2;
       reg [N-1:0] i;
       wire xSEL, accSIG;
       wire [WIO+WFO-1:0]xOut, xMUX;
       wire [N-1:0] oneHot, muxSEL;
       wire [WII+WFI-1:0] Coeff;
       wire [WIO+WFO-1:0] outMult, accOut, outAdd;
        
       xRAM DUT0 (.CLK(CLK), .RST(RST), .xSEL(xSEL), .xOut(xOut));
       Mult_Sel_MUX DUT1 (.oneHot(muxSEL), .x0(xOut), .x1(x1), .x2(x2), .xOutMux(xMUX));
       Coeff_MUX DUT2 (.oneHot(muxSEL), .Coeff(Coeff));
       Multiplier DUT3 (.RST(RST), .in1(xMUX), .in2(Coeff), .outMult(outMult));
       Adder DUT4 (.RST(RST), .in1(outMult), .in2(accOut), .outAdd(outAdd));
       Accumulator DUT5 (.CLK(CLK), .addIn(outAdd), .outSEL(outSEL), .RST(RST), .accOut(accOut), .firOut(y));
       Control_Unit DUT6 (.CLK(CLK), .RST(RST), .muxSEL(muxSEL), .xSEL(xSEL), .outSEL(outSEL));
       
       always_ff @(posedge CLK) begin
         if(RST) begin
            x1 <= 0;
            x2 <= 0;
            i <= 0;
         end
         else begin
            if(i < N) begin
                x1 <= x1;
                x2 <= x2;
                i = i+1;
            end
            else begin
                x1 <= xOut;
                x2 <= x1;
                i <=0;
            end
         end
       end
        
endmodule
