`timescale 1ns / 1ps

module Multiplier #(parameter WI1 = 2, WF1 = 6,
                                  WI2 = 2, WF2 = 6, 
                                  WIO = 2, WFO = 6)
    (input RST,
     input signed [WI1+WF1-1:0] in1,
     input signed [WI2+WF2-1:0] in2,
     output reg signed [WIO+WFO-1:0] outMult
     );

     reg [WI1+WI2+WF1+WF2-1 : 0] tempMult;
     reg [WI1+WI2-1 : 0] tempOutWIO;//[12:0]
     reg [WF1+WF2-1 : 0] tempOutWFO;//[6:0]
     reg [WIO-1 : 0] extendTempWIO;
     reg [WFO-1 : 0] extendTempWFO;
     reg [WI1+WI2-WIO : 0] temp; 
     reg signOut;
     reg OVF;
            
     always@* begin
        if(RST) begin
            outMult <= 0;
        end
          
         tempMult <= in1 * in2;

         tempOutWIO <= tempMult[WI1+WI2+WF1+WF2-1 : WF1+WF2];
         tempOutWFO <= tempMult[WF1+WF2-1 : 0];
         
        //case 1
        if(WIO > WI1+WI2+1) begin
            extendTempWIO <= $signed(tempOutWIO);
            OVF <= 0;
        end
        if(WFO > WF1+WF2+1) begin
            extendTempWFO <= {tempOutWFO,{(WFO - WF1+WF2){1'b0}}};
        end//end case 1
        
        //case 2
        if(WIO == WI1+WI2+1) begin
            extendTempWIO <= tempOutWIO[WI1+WI2 : 0];
            
            //check if in1/in2 had matching MSB and MSB of tempOut was oposite for OVF
            if((in1[WI1+WF1-1] & in2[WI2+WF2 -1]& ~tempMult[WI1+WI2+WF1+WF2-1]) || 
                 (~in1[WI1+WF1-1] & ~in2[WI2+WF2 -1] & tempMult[WI1+WI2+WF1+WF2-1])) begin 
                    OVF=1;
                 end
                 else begin
                    OVF=0;
                 end
        end
        if(WFO == WF1+WF2+1) begin
            extendTempWFO <= tempOutWFO[WF1+WF2-1 : 0];
        end
        
        //case 3
        if(WIO < WI1+WI2+1) begin
            temp <= tempOutWIO[WI1+WI2-1 : WIO-1];
            extendTempWIO <= {tempOutWIO[WI1+WI2-1], tempOutWIO[WIO-2 : 0]};
            
            if(((&temp) == 1) || (~(|temp) == 1)) begin
                OVF <= 0;
            end
            else begin
            OVF <= 1;
            end
        end
        if(WFO < WF1+WF2+1) begin
            extendTempWFO <= tempOutWFO[WF1+WF2-1 -: WFO];
        end//end case 3
         
         outMult = {extendTempWIO , extendTempWFO};
     end
      
endmodule
