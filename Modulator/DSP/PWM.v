/*
Code was designed and tested 
by Reevelen Dass for EEE5118Z practical and modified for this project.
*/

module PWM(
  input      ipClk,
  input      ipReset,
  input [7:0]ipDutyCycle,
  output reg opPWM
);


reg [7:0]Count;

reg nReset;
always @(posedge ipClk) nReset <= ~ipReset;


always @(posedge ipClk) begin
    if (nReset) begin
        if (ipDutyCycle > Count) 
            opPWM <= 1;
        else
            opPWM <= 0;

        Count <= Count + 1;

    end else begin
        Count <= 0;
    end
end

endmodule
