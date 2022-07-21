/*
Code was designed and tested 
by Reevelen Dass for EEE5118Z practical and modified for this project.
*/

import Structures::*;

module NCO(
  input ipClk,
  input ipReset,

  input [31:0]ipFrequency,

  output [17:0] opI,
  output [17:0] opQ
);
 
reg       Reset;
reg [31:0]Phase;  
  
reg nReset;
always @(posedge ipClk) nReset <= ~ipReset;

always @(posedge ipClk) begin
  if (!ipReset) begin
    Phase <= Phase + ipFrequency;
  end else begin
    Phase <= 0;
  end
end
 
SineTable Sine(
    .Clock(ipClk),
    .ClkEn(1'b1),
    .Reset(ipReset),
    .Theta(Phase[31:22]),
    .Sine(opI),
    .Cosine(opQ)
);

endmodule
