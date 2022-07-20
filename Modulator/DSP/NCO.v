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
  
always @(posedge ipClk) begin
  if (!ipReset) begin
    Phase <= Phase + 32'hFF000000;
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
