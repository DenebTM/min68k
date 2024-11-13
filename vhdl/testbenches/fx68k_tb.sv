`timescale 1ns

`define c_NO_DATA 4'bzzzz
`define c_INIT_DATA 4'b1000

module fx68k_tb;

  reg i_CLOCK   = 1'b0;

  // 68k signals
  reg         i_RESET   = 1'b1;
  reg         o_RESET;
  reg         o_HALTED;

  reg [2:0]   o_FC;

  reg         o_RW;
  reg         o_AS;
  reg         o_LDS;
  reg         o_UDS;
  reg         o_E;
  reg         o_VMA;
  reg         i_VPA     = 1'b1;
  reg         i_DTACK   = 1'b0;

  reg         i_BR      = 1'b1;
  reg         o_BG;
  reg         i_BGACK   = 1'b1;
  reg         i_BERR    = 1'b1;

  reg [15:0]  b_DATA;
  reg [23:0]  o_ADDR;

  fx68k cpu (
    .clk       (clk),
    .HALTn     (1'b1),

    .extReset  (i_RESET),
    .pwrUp     (i_RESET),
    .enPhi1    (1'b1),
    .enPhi2    (1'b1),

    .eRWn      (o_RW),
    .ASn       (o_AS),
    .LDSn      (o_LDS),
    .UDSn      (o_UDS),
    .E         (o_E),
    .VMAn      (o_VMA),

    .FC0       (o_FC[0]),
    .FC1       (o_FC[1]),
    .FC2       (o_FC[2]),
    .BGn       (o_BG),
    .oRESETn   (o_RESET),
    .oHALTEDn  (o_HALTED),
    .DTACKn    (i_DTACK),
    .VPAn      (i_VPA),
    .BERRn     (i_BERR),
    .BRn       (i_BR),
    .BGACKn    (i_BGACK),
    .IPL0n     (1'b1),
    .IPL1n     (1'b1),
    .IPL2n     (1'b1),

    .iEdb      (b_DATA),
    .oEdb      (b_DATA),
    .eab       (o_ADDR[23:1])
  );

  // clock generator
  always #125 i_CLOCK <= !i_CLOCK;

  always @ (negedge i_RESET) $display("reset lo");
  always @ (posedge i_RESET) $display("reset hi");

  // test process
  initial begin

    i_RESET <= 1'b0;
    #10ms

    i_RESET <= 1'b1;
    #90ms

    $display("test complete");
  end

endmodule
