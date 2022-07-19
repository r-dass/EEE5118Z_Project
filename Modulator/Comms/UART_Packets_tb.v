`timescale 1ns/1ns // unit/precision
import Structures::*;
module UART_Packets_tb;

  reg ipClk = 0;
  always #10 ipClk <= ~ipClk;

  reg ipReset = 1;
  initial
  begin
    @(posedge ipClk);
    @(posedge ipClk);
    @(posedge ipClk);
    ipReset <= 0;
  end

  UART_PACKET TxPacket;
  reg opTxReady;
  reg opTx;

  reg ipRx;
  UART_PACKET RxPacket;

  UART_Packets DUT(
        .ipClk              (ipClk      ),
        .ipReset            (ipReset    ),

        .ipTxStream         (TxPacket   ),
        .opTxReady          (opTxReady  ),
        .opTx               (opTx       ),

        .ipRx               (ipRx       ),
        .opRxStream         (RxPacket   )
    );

assign ipRx = opTx; 

  initial begin
    TxPacket.Destination <= 8'h56;
    TxPacket.Source <= 8'h57;
    TxPacket.Length <= 1;
    TxPacket.Data <= 8'h58;
    TxPacket.EoP <= 1;
    TxPacket.SoP <= 1;
    TxPacket.Valid <= 0;

    while (!opTxReady) #10;

    #100
    TxPacket.Valid <= 1;
  end
endmodule
