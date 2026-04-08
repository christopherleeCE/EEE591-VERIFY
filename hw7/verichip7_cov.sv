module verichip7_cov (input logic clk,                       // system clock
                      input logic rst_b,                     // chip reset
                      input logic export_disable,            // disable features
                      input logic interrupt_1,               // first interrupt
                      input logic interrupt_2,               // second interrupt

                      input logic maroon,                    // maroon state machine input
                      input logic gold,                      // gold state machine input

                      input logic chip_select,               // target of r/w
                      input logic [6:0] address,             // address bus
                      input logic [1:0] byte_en,             // write byte enables
                      input logic       rw_,                 // read/write
                      input logic [15:0] data_in,            // input data bus

                      input logic [15:0] data_out,           // output data bus

                      input logic        valid,              // ALU command is valid
                      input logic [3:0]  cmd,                // the ALU command
                      input logic [3:0]  state,              // the current state
                      input logic [15:0] alu_left,
                      input logic [15:0] alu_right,
                      input logic [15:0] alu_out);

localparam VCHIP_ALU_VER = 4'h2;    // current ALU version
localparam VCHIP_MAJ_VER = 4'h1;
localparam VCHIP_MIN_VER = 4'h0;

localparam VCHIP_STATE_RESET = 4'h0;
localparam VCHIP_STATE_NORM  = 4'h1;
localparam VCHIP_STATE_ERR   = 4'h2;
localparam VCHIP_STATE_EXP   = 4'h8;
localparam VCHIP_STATE_LOST  = 4'hF;

localparam VCHIP_ADDR_VER = 7'h00;
localparam VCHIP_ADDR_STA = 7'h04;
localparam VCHIP_ADDR_CMD = 7'h08;
localparam VCHIP_ADDR_CON = 7'h0C;
localparam VCHIP_ADDR_LFT = 7'h10;
localparam VCHIP_ADDR_RGT = 7'h14;
localparam VCHIP_ADDR_ALU = 7'h18;

localparam VCHIP_CMD_NONE = 4'h0;

localparam VCHIP_STA_INT2 = 9;      // bit position of interrupt 2
localparam VCHIP_STA_INT1 = 8;      // bit position of interrupt 1

localparam VCHIP_CMD_LEFT = 3;      // left bit of command in command register
localparam VCHIP_CMD_VAL  = 15;     // valid bit
localparam VCHIP_CMD_NON = 0;
localparam VCHIP_CMD_ADD = 1;
localparam VCHIP_CMD_SUB = 2;
localparam VCHIP_CMD_MVL = 3;
localparam VCHIP_CMD_MVR = 4;
localparam VCHIP_CMD_SWA = 5;
localparam VCHIP_CMD_SHL = 6;
localparam VCHIP_CMD_SHR = 7;
localparam VCHIP_LAST_CMD = 7;
localparam VCHIP_LAST_EXP_CMD = 2;

// Your covergroups go here!

endmodule // verichip7_cov

