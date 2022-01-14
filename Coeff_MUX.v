`timescale 1ns / 1ps

//uses a onehot input select ot get address to H LUT
module Coeff_MUX #(parameter N = 3,
                             WIO = 2, WFO = 6)
                  (input [N-1:0] oneHot,
                   output reg [WIO+WFO-1:0] Coeff);
                   
       reg [31:0] coefficient [0:127];
       reg [31:0] readData;
       
       initial $readmemb("Coeff.dat", coefficient);
    
       always_comb begin
           for(int i = 0; i < N; i++) begin
               if(oneHot == (1 << i)) begin
                    readData <= coefficient[i];
                    Coeff <= readData[7:0];
                end
                else
                    Coeff = 0;
           end
       end
       
endmodule
