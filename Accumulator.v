`timescale 1ns / 1ps


module Accumulator #(parameter N = 3,
                              WII = 2, WFI = 6,
                              WIO = 2, WFO = 6)

                    (input CLK, RST, outSEL,
                     input [WII+WFI-1:0] addIn,
                     output reg [WIO+WFO-1:0] accOut, firOut);
                     
       reg [N-1:0] i;
       
       always_ff @(posedge CLK) begin
        if(RST) begin
            firOut <= 0;
            accOut <= 0;
        end
        else begin
          if(outSEL) begin
            firOut <= addIn;
            accOut <= 0;
          end
          else begin
             accOut <= addIn; 
             firOut <= firOut; 
          end         
        end
       end
endmodule
