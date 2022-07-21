/*
Code was designed and tested 
by Reevelen Dass for this project.
*/

import Structures::*;

module QAM(
    input              			ipClk,
    input              			ipReset,

    input      [3:0]            ipQAMBlock,
    input                      ipQAMBlockValid,

    input      signed [17:0] ipI,
    input      signed [17:0] ipQ,

    output     reg opModulatedValid,
    output     reg[19:0] opModulated
); 
reg nReset;
always @(posedge ipClk) nReset <= ~ipReset;

always @(posedge(ipClk)) begin
    if (nReset) begin
        opModulatedValid <= ipQAMBlockValid;
        case (ipQAMBlock)
            4'b0000: begin
                opModulated <= ipI + ipQ;
            end
            4'b0001: begin
                opModulated <= 3*ipI + ipQ;
            end
            4'b0010: begin
                opModulated <= -ipI + ipQ;
            end
            4'b0011: begin
                opModulated <= -3*ipI + ipQ;
            end
            4'b0100: begin
                opModulated <= ipI + 3*ipQ;
            end
            4'b0101: begin
                opModulated <= 3*ipI + 3*ipQ;
            end
            4'b0110: begin
                opModulated <= -ipI + 3*ipQ;
            end
            4'b0111: begin
                opModulated <= -3*ipI + 3*ipQ;
            end
            4'b1000: begin
                opModulated <= ipI - ipQ;
            end
            4'b1001: begin
                opModulated <= 3*ipI - ipQ;
            end
            4'b1010: begin
                opModulated <=  -ipI - ipQ;
            end
            4'b1011: begin
                opModulated <= -3*ipI - ipQ;
            end
            4'b1100: begin
                opModulated <= ipI - 3* ipQ;
            end
            4'b1101: begin
                opModulated <= 3*ipI - 3* ipQ;
            end
            4'b1110: begin
                opModulated <= -ipI - 3* ipQ;
            end
            4'b1111: begin
                opModulated <= -3*ipI -3*ipQ;
            end
        endcase
    end else  begin
        opModulated <= 0;
        opModulatedValid <= 0;
    end

end

endmodule