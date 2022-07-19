import Structures::*;
//------------------------------------------------------------------------------
module Controller(
    input               ipClk,
    input               ipReset,

    output  UART_PACKET 	opTxStream,
    input					ipTxReady,

	output  reg [7:0]   	opAddress,
    output  reg [31:0]  	opWrData,
	output  reg         	opWrEnable,
	
	input   UART_PACKET 	ipRxStream,

    input   [31:0]   	ipRdData 
);

enum {
	Wait,
	tRead,
	Write
} State;

enum {
	TransmitAddress,
	TransmitPayload,
	TransmitComplete,
	TransmitWait
} tState;

reg [7:0] 	BytesWritten;
reg [31:0] OutputData;

always @ (posedge(ipClk)) begin
	if (!ipReset) begin
		case (State)
			Wait: begin
				opWrEnable <= 0;
				
				opTxStream.SoP   <= 0;
				opTxStream.EoP   <= 0;
				opTxStream.Valid <= 0;
				
				BytesWritten <= 0;
				
				if(ipRxStream.Valid && ipRxStream.SoP) begin
					opAddress <= ipRxStream.Data;

					if (ipRxStream.Destination == 0) begin
						State <= tRead;
					end   
					if (ipRxStream.Destination == 1) begin	
						State <= Write;
					end
				end
			end
			Write: begin
				if (ipRxStream.Valid) begin
					opWrData <= {ipRxStream.Data, opWrData[31:8]};
					BytesWritten <= BytesWritten + 1;

					if (BytesWritten == 3) begin
						State <= Wait;
						opWrEnable <= 1;
					end

				end
			end 
			tRead: begin
				case (tState)
					TransmitWait: begin // Wait for registers to output correct data
						tState <= TransmitAddress;
					end
					TransmitAddress: begin
						opTxStream.SoP   		<= 1;
						opTxStream.Source      	<= ipRxStream.Destination;
						opTxStream.Destination 	<= ipRxStream.Source;
						opTxStream.Length      	<= 8'h05;
						opTxStream.Data			<= opAddress;
						OutputData 				<= ipRdData;
						
  
						if(ipTxReady) begin
							opTxStream.Valid <= 1;
							tState <= TransmitPayload;
						end
					end
					TransmitPayload: begin
						if(ipTxReady) begin
							opTxStream.SoP   <= 0;
							opTxStream.Data  <= OutputData[7:0];
							OutputData <= {8'hX, OutputData[31:8]};

							BytesWritten <= BytesWritten + 1;

							if(BytesWritten == 3) begin
								opTxStream.EoP <= 1;
								tState <= TransmitComplete;
							end	
						end
					end
					TransmitComplete: begin
						if (ipTxReady) begin
							opTxStream.Valid <= 0;
							opTxStream.EoP <= 0;
							tState <= TransmitWait;
							State <= Wait;
						end
					end
					default:;
				endcase 
			end
		 	default:;	
		endcase
	end else begin // reset code here
		BytesWritten <= 0;
		OutputData <= 0;
		State <= Wait;
		tState <= TransmitWait;
	end
end

endmodule
//------------------------------------------------------------------------------
