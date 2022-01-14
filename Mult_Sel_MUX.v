`timescale 1ns / 1ps


module Mult_Sel_MUX #(parameter N = 3,
                                WII = 2, WFI = 6,
                                WIO = 2, WFO = 6)
                    (
                     input [WII+WFI-1:0] x0, x1, x2,
                     input [N-1:0] oneHot,
                     output reg [WIO+WFO-1:0] xOutMux);
   
       always_comb begin
            if(oneHot == 3'b001)
                xOutMux <= x0;
            else if(oneHot == 3'b010)
                xOutMux <= x1;
            else if(oneHot == 3'b100)
                xOutMux <= x2;
            else
                xOutMux <= 0;
       end
       
                
endmodule
