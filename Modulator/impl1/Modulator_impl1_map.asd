[ActiveSupport MAP]
Device = LFXP2-5E;
Package = TQFP144;
Performance = 6;
LUTS_avail = 4752;
LUTS_used = 1356;
FF_avail = 3664;
FF_used = 453;
INPUT_LVCMOS33 = 7;
OUTPUT_LVCMOS33 = 12;
IO_avail = 100;
IO_used = 19;
PLL_avail = 2;
PLL_used = 0;
EBR_avail = 9;
EBR_used = 2;
;
; start of DSP statistics
MULT36X36B = 0;
MULT18X18B = 0;
MULT18X18MACB = 0;
MULT18X18ADDSUBB = 0;
MULT18X18ADDSUBSUMB = 0;
MULT9X9B = 0;
MULT9X9ADDSUBB = 0;
MULT9X9ADDSUBSUMB = 0;
DSP_avail = 24;
DSP_used = 0;
; end of DSP statistics
;
; Begin EBR Section
Instance_Name = Streamer1/FIFOBLOCK/pdp_ram_0_3_0;
Type = DP16KB;
Width_B = 4;
Depth_A = 4096;
Depth_B = 4096;
REGMODE_A = OUTREG;
REGMODE_B = OUTREG;
RESETMODE = ASYNC;
WRITEMODE_A = NORMAL;
WRITEMODE_B = NORMAL;
GSR = DISABLED;
MEM_LPC_FILE = FIFO.lpc;
Instance_Name = Streamer1/FIFOBLOCK/pdp_ram_0_2_1;
Type = DP16KB;
Width_B = 4;
Depth_A = 4096;
Depth_B = 4096;
REGMODE_A = OUTREG;
REGMODE_B = OUTREG;
RESETMODE = ASYNC;
WRITEMODE_A = NORMAL;
WRITEMODE_B = NORMAL;
GSR = DISABLED;
MEM_LPC_FILE = FIFO.lpc;
; End EBR Section
