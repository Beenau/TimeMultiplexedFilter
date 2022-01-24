`timescale 1ns / 1ps


module Adder #(parameter WI1 = 2, WF1 = 6,
                              WI2 = 2, WF2 = 6, 
                              WIO = 2, WFO = 6)
    (input RST,
     input signed [WI1+WF1-1:0] in1,
     input signed [WI2+WF2-1:0] in2,
     output reg signed [WIO+WFO-1:0] outAdd);
     
     localparam MAXWI = (WI1 > WI2) ? WI1 : WI2;
     localparam MAXWF = (WF1 > WF2) ? WF1 : WF2;

     reg [WI1-1 : 0] nonExtendWI1;
     reg [MAXWI-1 : 0] extendWI1;
     reg [WI2-1 : 0] nonExtendWI2;
     reg [MAXWI-1 : 0] extendWI2;
     
     reg [WF1-1 : 0] nonExtendWF1;
     reg [MAXWF-1 : 0] extendWF1;
     reg [WF2-1 : 0] nonExtendWF2;
     reg [MAXWF-1 : 0] extendWF2;
     
     reg [MAXWI+MAXWF-1 : 0] alignedIn1;
     reg [MAXWI+MAXWF-1 : 0] alignedIn2;
     
     //add one bit to the aligned for OVF
     reg OVF;
     reg [MAXWI+MAXWF : 0] alignedOvfIn1;
     reg [MAXWI+MAXWF : 0] alignedOvfIn2;
     
     reg [MAXWI+MAXWF : 0] tempOut;
     reg [MAXWI : 0] tempWIO;
     reg [MAXWF-1 : 0] tempWFO;
     reg [WIO : 0] extendTempWIO;
     reg [WFO-1 : 0] extendTempWFO;
     reg [MAXWI-WIO+1 : 0] temp;  //holds dropped bits in case 3

    always@* begin  
        if(RST) begin
            outAdd <= 0;
        end
        
        if(WI1 > WI2) begin
            nonExtendWI2 <= in2[WI2+WF2-1 : WF2];
            extendWI2 <= $signed(nonExtendWI2);
            extendWI1 <= in1[WI1+WF1-1 : WF1];
        end
        if(WI2 > WI1) begin
            nonExtendWI1 <= in1[WI1+WF1-1 : WF1];
            extendWI1 <= $signed(nonExtendWI1);
            extendWI2 <= in2[WI2+WF2-1 : WF2];
        end
        if(WI1 == WI2) begin
            extendWI1 <= in1[WI1+WF1-1 : WF1];
            extendWI2 <= in2[WI2+WF2-1 : WF2];
        end
        if(WF1 > WF2) begin
            nonExtendWF2 <= in2[WF2-1 : 0];
            extendWF2 <= {nonExtendWF2,{(WF1 - WF2){1'b0}}};
            extendWF1 <= in1[WF1-1 : 0];
        end
        if(WF2 > WF1) begin
            nonExtendWF1 <= in1[WF1-1 : 0];
            extendWF1 <= {nonExtendWF1,{(WF2 - WF1){1'b0}}};
            extendWF2 <= in2[WF2-1 : 0];
        end
        if(WF1 == WF2) begin
            extendWF1 <= in1[WF1-1 : 0];
            extendWF2 <= in2[WF2-1 : 0];
        end
        
        alignedIn1 <= {extendWI1 , extendWF1};
        alignedIn2 <= {extendWI2 , extendWF2};
        
        //sign extend 1 bit to account for OVF
        alignedOvfIn1 <= $signed(alignedIn1);
        alignedOvfIn2 <= $signed(alignedIn2);
        
        tempOut <= alignedOvfIn1 + alignedOvfIn2;
        //top 8-bits of the addition is WIO
        tempWIO <= tempOut[MAXWI+MAXWF : MAXWF];
        //bottum four bits are WFO
        tempWFO <= tempOut[MAXWF-1 : 0];

        //case 1
        if(WIO > MAXWI) begin
            extendTempWIO <= $signed(tempWIO);
            OVF <= 0;
        end
        if(WFO > MAXWF+1) begin
            extendTempWFO <= {tempWFO,{(WFO - MAXWF){1'b0}}};
        end//end case 1
        
        //case 2
        if(WIO == MAXWI) begin
            extendTempWIO <= tempWIO[MAXWI : 0];
            
            //check if in1/in2 had matching MSB and MSB of tempOut was oposite for OVF
            if((in1[WI1+WF1-1] & in2[WI2+WF2 -1]& ~tempOut[MAXWI+MAXWF]) || 
                 (~in1[WI1+WF1-1] & ~in2[WI2+WF2 -1] & tempOut[MAXWI+MAXWF])) begin 
                    OVF=1;
                 end
                 else begin
                    OVF=0;
                 end
        end
        if(WFO == MAXWF+1) begin
            extendTempWFO <= tempWFO[MAXWF-1 : 0];
        end
        
        //case 3
        if(WIO < MAXWI) begin
            temp <= tempWIO[MAXWI : WIO-1];
            extendTempWIO <= {tempWIO[MAXWI], tempWIO[WIO-2 : 0]};
            
            if(((&temp) == 1) || (~(|temp) == 1)) begin
                OVF <= 0;
            end
            else begin
            OVF <= 1;
            end
        end
        if(WFO < MAXWF+1) begin
            extendTempWFO <= tempWFO[MAXWF-1 -: WFO];
        end//end case 3
        
        outAdd <= {extendTempWIO[WIO-1:0], extendTempWFO}; 
       end
            
endmodule
