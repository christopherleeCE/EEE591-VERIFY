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


covergroup colors @ ( posedge clk);
cp_gold: coverpoint gold;
cp_maroon: coverpoint maroon;
cx_colors: cross cp_gold, cp_maroon;
endgroup
colors colors_i = new();


covergroup alu_regs @ ( negedge clk);
cp_alu_left: coverpoint alu_left { bins range[4] = {[0:$]}; }
cp_alu_right: coverpoint alu_right { bins range[4] = {[0:$]}; }
cp_cmd: coverpoint cmd {bins non = { VCHIP_CMD_NON };
            bins add = { VCHIP_CMD_ADD };
            bins sub = { VCHIP_CMD_SUB };
            bins mvl = { VCHIP_CMD_MVL };
            bins mvr = { VCHIP_CMD_MVR };
            bins swa = { VCHIP_CMD_SWA };
            bins shl = { VCHIP_CMD_SHL };
            bins shr = { VCHIP_CMD_SHR };
            bins undefined = { [8:15] };}
cp_valid: coverpoint valid {bins not_valid = { 0 };
                bins valid = { 1 };}

cp_norm_valid: coverpoint valid {bins not_valid = { 0 };
                bins valid = { 1 };}
cp_reset_valid: coverpoint valid {bins not_valid = { 0 };
                bins valid = { 1 };}
cp_state: coverpoint state{bins reset = { VCHIP_STATE_RESET };
                bins normal = { VCHIP_STATE_NORM };
                bins error = { VCHIP_STATE_ERR };
                bins exp_vio = { VCHIP_STATE_EXP };}
cx_norm_cmd_valid: cross cp_cmd, cp_norm_valid;
cx_reset_cmd_valid: cross cp_cmd, cp_reset_valid;
cx_cmd_valid: cross cp_cmd, cp_valid;
cx_cmd_valid_state: cross cp_cmd, cp_valid,cp_state;
cx_alu_lr: cross cp_alu_left, cp_alu_right;
endgroup // alu_regs

alu_regs alu_regs_i = new();

covergroup inters @(negedge clk);
cp_int1: coverpoint interrupt_1;
cp_int2: coverpoint interrupt_2;
cx_ints: cross cp_int1, cp_int2;
endgroup
inters inters_i = new();

covergroup bus_interface @(posedge clk);
cp_cs: coverpoint chip_select {bins non_selected = {0};
                               bins selected = {1};}
cp_rw: coverpoint rw_ {bins write = {0};
                       bins read = {1};}
cp_bytes: coverpoint byte_en{bins neither = {0};
                             bins byte0 = {1};
                             bins byte1 = {2};
                             bins both = {3};}
cp_data_in: coverpoint data_in{bins range[8] = {[0:$]};}
cp_address: coverpoint address{bins ver = {VCHIP_ADDR_VER};
                               bins sta = {VCHIP_ADDR_STA};
                               bins cmd = {VCHIP_ADDR_CMD};
                               bins con = {VCHIP_ADDR_CON};
                               bins lft = {VCHIP_ADDR_LFT};
                               bins rgt = {VCHIP_ADDR_RGT};
                               bins alu = {VCHIP_ADDR_ALU};}

cx_cs_rw_be: cross cp_cs, cp_rw, cp_bytes;
cx_cs_rw_add: cross cp_cs, cp_rw, cp_address;
endgroup

bus_interface bus_interface_i = new();
//cp_state: coverpoint state
//{
//bins reset = { VCHIP_STATE_RESET };
//bins normal = { VCHIP_STATE_NORM };
//bins error = { VCHIP_STATE_ERR };
//bins exp_vio = { VCHIP_STATE_EXP };
//}
//cp_cmd: coverpoint cmd
//{
//bins non = { VCHIP_CMD_NON };
//bins add = { VCHIP_CMD_ADD };
//bins sub = { VCHIP_CMD_SUB };
//bins mvl = { VCHIP_CMD_MVL };
//bins mvr = { VCHIP_CMD_MVR };
//bins swa = { VCHIP_CMD_SWA };
//bins shl = { VCHIP_CMD_SHL };
//bins shr = { VCHIP_CMD_SHR };
//bins undefined = { [8:15] };
//}


endmodule // verichip7_cov
