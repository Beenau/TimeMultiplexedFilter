`timescale 1ns / 1ps

module Control_Unit #(parameter N = 3,
                              WII = 2, WFI = 6,
                              WIO = 2, WFO = 6)

                    (input CLK, RST,
                     output reg xSEL, outSEL,
                     output reg [N-1:0] muxSEL);
       
       reg [N-1:0] i;       
                     
       always_ff @(posedge CLK) begin
        if(RST) begin
            i <= 0;
            xSEL <= 1;
            muxSEL <= 1;
            outSEL = 0;
        end
        else begin
            if(i < N) begin
                xSEL <= 0;
                outSEL <= 0;
                muxSEL <= 1 << i;
                i = i + 1;
            end
            else begin
                xSEL <= 1;
                outSEL <= 1;
                muxSEL <= 0;
                i = 0;
            end
        end       
       end
endmodule
