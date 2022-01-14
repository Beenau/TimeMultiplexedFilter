`timescale 1ns / 1ps

//Use for simulation, hardware will handle input RAM when implemented on board

module xRAM #(parameter N = 3,
                        WII = 2, WFI = 6,
                        WIO = 2, WFO = 6)
            (input CLK, RST, xSEL,
             output reg [WIO+WFO-1:0] xOut);
             
       reg [31:0] DATA [0:127]; 
       reg [31:0] readData; 
       reg [N-1:0] i; 
       initial $readmemb("inputs.dat", DATA);
       
       
       always_ff @(posedge CLK) begin
          if(RST) begin
            xOut <= 0; 
            i <= 0;
          end
          else begin
            if(xSEL) begin
             xOut <= DATA[i]; 
             i <= i+1;
            end
          end          
       end
endmodule
