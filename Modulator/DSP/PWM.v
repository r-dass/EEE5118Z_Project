module PWM(
  input      ipClk,
  input      ipReset,
  input [7:0]ipDutyCycle,
  output reg opPWM
);


reg [7:0]Count;

always @(posedge ipClk) begin
    if (!ipReset) begin
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
