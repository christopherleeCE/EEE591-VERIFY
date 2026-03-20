///////////////////////////////////////////
// Christopher Lee; Nick Marta; Andy Cox V
// EEE598: Digital Verification & Test
// Dr. Steven Millman
// Spring 2026
// 20 MAR 2026

`timescale 1ns/1ps
// performed in 0 time

`define DISPLAY_STATE \
   if(verichip.state == 0) begin       \
         $display("state: reset");       \
   end else if(verichip.state == 1) begin       \
         $display("state: normal");       \
   end else if(verichip.state == 2) begin       \
         $display("state: err0r");       \
   end else if(verichip.state == 8) begin       \
         $display("state: expvi");       \
   end


`define SET_WRITE(addr,val,bytes,cs)   \
   rw_ <= 1'b0;                     \
   chip_select <= cs;               \
   byte_en <= bytes;                \
   address <= addr;                 \
   data_in <= val;

`define SET_READ(addr,cs)           \
   rw_ <= 1'b1;                     \
   chip_select <= cs;               \
   byte_en <= 2'b00;                \
   address <= addr;                 \
   data_in <= 16'h0;

// sets everything to "active" values
`define CLEAR_BUS                   \
   chip_select    <= 1'b0;          \
   address        <= 7'h0;          \
   byte_en        <= 2'h0;          \
   rw_            <= 1'b1;          \
   data_in        <= 16'h0;

`define CLEAR_ALL                   \
   export_disable <= 1'b0;          \
   maroon         <= 1'b0;          \
   gold           <= 1'b0;          \
   `CLEAR_BUS

`define WRITE_REG(addr,wval,bytes,cs) \
   wait(clk == 1'b0); \
   `SET_WRITE(addr,wval,bytes,cs) \
   wait(clk == 1'b1); \
   `CLEAR_BUS \
   wait(clk == 1'b0);

`define READ_REG(addr,cs) \
   wait(clk == 1'b1); \
   `SET_READ(addr,cs) \
   wait(clk == 1'b0); \
   wait(clk == 1'b1);

//give it a value, if the data_out on the data bus is not that value, throw an error
`define CHECK_VAL(exp_val)                                      \
  if (data_out != exp_val)                                      \
        $display("Bad read: [data_out, expected] = [%h, %h]", data_out, exp_val);

// check the value in the ALU left register
`define CHECK_ALU_LEFT(exp_val)                                      \
   if ( verichip.alu_left != exp_val )                               \
      $display(" Bad read: [data_out, expected] = [%h, %h]", verichip.alu_left, exp_val);

// perform a write and verify it with a read
`define CHECK_RW(addr,wval,exp_val,bytes,cs)    \
   `WRITE_REG(addr,wval,bytes,cs)               \
   `READ_REG(addr,cs)                           \
   `CHECK_VAL(exp_val)

// Ensures that reading from addresses not linked to an address given regardless of cs value
// expecting 0x0000 covers exp vio and writing 0xFFFF to the target register ensures that no bit fields associated
// with aliased registers can be flipped from 0 to 1
`define ALIASING_READ_CHECK(addr, exp_val,write_val)            \
    `WRITE_REG(addr, write_val, 2'b11, 1'b1) \
    for(int ii = 0; ii < 128; ++ii)          \
    begin                                      \
      if((ii != VCHIP_ALU_OUT_ADDR) && (ii != VCHIP_ALU_RIGHT_ADDR) && (ii != VCHIP_ALU_LEFT_ADDR) && (ii != VCHIP_CON_ADDR) && (ii != VCHIP_CMD_ADDR) && (ii != VCHIP_STA_ADDR) && (ii != VCHIP_VER_ADDR)) begin  \
         // read with cs high                \
         `READ_REG(ii, 1'b1)                 \
                                             \
         if (data_out != 16'h0000)           \
         $display("alias read check Bad read: [data_out, expected] = [%h, %h]", data_out, exp_val); \
         // read with cs low                       \
         `READ_REG(ii, 1'b0)                      \
                                                   \
         if (data_out != 16'h0000)                 \
         $display("alias read check Bad read: [data_out, expected] = [%h, %h]", data_out, exp_val); \
      end                                          \
   end                                             
    
// Write 16'h0000 to the address of interest and validate an aliased write does not affect reg value for cs = 0 and cs = 1
// expecting 16'h0000 also covers export violation so a new macro does not have to be made
// NOTE, aliased registers have 0xFFFF writen to them to check that no bit fields in ALU left go from 0 => 1
`define ALIASING_WRITE_CHECK(addr,bytes = 2'b11,cs,exp_val) //TODO need to havea  for loop for all byte enables\
for (int ii = 0 ; ii < 128 ; ++ii) begin  \
      // Do not check/overrite known good registers/addresses \
      if((ii != VCHIP_ALU_OUT_ADDR) && (ii != VCHIP_ALU_RIGHT_ADDR) && (ii != VCHIP_ALU_LEFT_ADDR) && (ii != VCHIP_CON_ADDR) && (ii != VCHIP_CMD_ADDR) && (ii != VCHIP_STA_ADDR) && (ii != VCHIP_VER_ADDR)) begin  \
         `CHECK_RW(addr, 16'h0000, exp_val, 2'b11, 1'b1)      \
                                                   \
         `WRITE_REG(ii, 16'hFFFF, bytes, cs)          \
         `READ_REG(addr, 1'b1)                    \
                                                   \
         if (data_out != exp_val)                 \
                $display("alias write Bad read: @ %d [data_out, expected] = [%h, %h]", ii, data_out, exp_val); \
                                                   \
      end                                          \
end                                              

//TODO at addr = 0 reg_val is completly bypassed, look into l8r
`define GEN_EXP_VAL(wr_val, bit_enable, reg_val, access_array, reg_addr, out_reg) \
//$display("%h %h %p %h", wr_val, reg_val, access_array, out_reg);  \
//$display("reg_addr = %d | cmp result %d", reg_addr, reg_addr != 7'h0); \
if(reg_addr != 0) begin                    \
   for (int i = 0; i < 16; ++i) begin         \
      //$write(" %0d", access_array[i]);      \
      case (access_array[i])                  \
         RO:                                  \
            out_reg[i] = reg_val[i];  \
         W1C:                                 \
            out_reg[i] = ~wr_val[i] & reg_val[i] & ~bit_enable[i]; \
         RW:                                      \
            out_reg[i] =  wr_val[i] & bit_enable[i];      \
         default:                                 \
            out_reg[i] = reg_val[i] & bit_enable[i];      \
                                                  \
      endcase                                     \
   end                                            \
end                                          \
else begin                                    \
   //$display("else execd");                      \
   out_reg = 16'h0210;     //TODO maybe remove if? and put reg_val manually \
end                                    

// waits for the clock to be 0 and then asserts reset, then waits for 
// clk == 1 to deassert reset
`define CHIP_RESET                  \
   wait( clk == 1'b0 );             \
   rst_b <= 1'b0;                   \
   wait( clk == 1'b1 );             \
   rst_b <= 1'b1;

// go into normal state
`define CHIP_NORMAL    \
   wait(clk == 1'b0);  \
   rst_b <= 1'b0;      \
   wait(clk == 1'b1);  \
   rst_b <= 1'b1;      \
   wait(clk == 1'b0);  \
                       \
   //go into normal from reset \
   maroon <= 1'b0;     \
   gold <= 1'b1;       \
   wait(clk == 1'b1);  \
   wait(clk == 1'b0);  \

// go into error state
//inital value is a raw 16h that goes into the CHECK_RW, not gaurenteed to actually write, depeding on the register
`define CHIP_ERROR(init_value, int1_en)  \
   wait(clk == 1'b0);  \
   rst_b <= 1'b0;      \
   wait(clk == 1'b1);  \
   rst_b <= 1'b1;      \
   wait(clk == 1'b0);  \
                       \
   //go into normal from reset \
   maroon <= 1'b0;     \
   gold <= 1'b1;       \
   wait(clk == 1'b1);  \
   wait(clk == 1'b0);  \
                       \
   //set to a non-zero initial value               \
   // `CHECK_RW(VCHIP_VER_ADDR, init_value, 16'h0210, 2'b11, 1'b1)     \
   //`CHECK_RW(VCHIP_STA_ADDR, init_value, init_value, 2'b11, 1'b1)     \
   // $display("0"); \
   `CHECK_RW(VCHIP_CMD_ADDR, init_value, init_value, 2'b11, 1'b1)     \
   $display("1");                                                                \
   if (int1_en == 1)                                                                \
   begin                                                                            \
      // `CHECK_RW(VCHIP_CON_ADDR, init_value, (init_value & 16'h0300), 2'b11, 1'b1)   \
      // init_value = 16'h0300;                                                        \
      `CHECK_RW(VCHIP_CON_ADDR, 16'h0300, (16'h0300), 2'b11, 1'b1)     \
   end                                                                              \
   // $display("2"); \
   `CHECK_RW(VCHIP_ALU_LEFT_ADDR, init_value, init_value, 2'b11, 1'b1)     \
   // $display("3"); \
   `CHECK_RW(VCHIP_ALU_RIGHT_ADDR, init_value, init_value, 2'b11, 1'b1)     \
   // $display("4"); \
   `CHECK_RW(VCHIP_ALU_OUT_ADDR, init_value, 16'h0000, 2'b11, 1'b1)     \
                                                         \
   //write bad command to command reg to go into error   \
   `WRITE_REG(VCHIP_CMD_ADDR, 16'h800C, 2'b11, 1'b1)     \
   wait(clk == 1'b1); wait(clk == 1'b0); //min wait to see state change debug output   \

   // go into chip exp state
   `define CHIP_EXP_VIO    \
                        \
   wait(clk == 1'b0);   \
   rst_b <= 1'b0;       \
   wait(clk == 1'b1);   \
   rst_b <= 1'b1;       \
   wait(clk == 1'b0);   \
                        \
   //go into normal from reset \
                        \
   maroon <= 1'b0;      \
   gold <= 1'b1;        \
   wait(clk == 1'b1);   \
   wait(clk == 1'b0);   \
                        \
   export_disable <= 1'b1; \
                        \
   //write restricted cmd to command reg to go into error   \
   //(even invalid commands are restricted)                 \
   `WRITE_REG(VCHIP_CMD_ADDR, 16'h8008, 2'b11, 1'b1)                                   \
   wait(clk == 1'b1); wait(clk == 1'b0); //min wait to see state change debug output   \

   `define RESET_STATE_CHECK(stim,M,G,exp_vio,bad_cmd) \
   `CHIP_RESET          \
    maroon <= M;     \
    gold <= G;       \
    
    


module top_verichip4 ();

//TODO remove FAIL in debug output

localparam RO = 2'b0;
localparam W1C = 2'b1;
localparam RW = 2'b10;

logic clk;                       // system clock
logic rst_b;                     // chip reset
logic export_disable;            // disable features
logic interrupt_1;               // first interrupt
logic interrupt_2;               // second interrupt

logic maroon;                    // maroon state machine input
logic gold;                      // gold state machine input

logic chip_select;               // target of r/w
logic [6:0] address;             // address bus
logic [1:0] byte_en;             // write byte enables
logic       rw_;                 // read/write
logic [15:0] data_in;            // input data bus

logic [15:0] data_out;           // output data bus

localparam VCHIP_VER_ADDR       = 7'h00;
localparam VCHIP_STA_ADDR       = 7'h04;
localparam VCHIP_CMD_ADDR       = 7'h08;
localparam VCHIP_CON_ADDR       = 7'h0C;
localparam VCHIP_ALU_LEFT_ADDR  = 7'h10;
localparam VCHIP_ALU_RIGHT_ADDR = 7'h14;
localparam VCHIP_ALU_OUT_ADDR   = 7'h18;

localparam VCHIP_ALU_VALID = 16'h8000;
localparam VCHIP_ALU_ADD   = 16'h0001;
localparam VCHIP_ALU_SUB   = 16'h0002;
localparam VCHIP_ALU_MVL   = 16'h0003;
localparam VCHIP_ALU_MVR   = 16'h0004;
localparam VCHIP_ALU_SWA   = 16'h0005;
localparam VCHIP_ALU_SHL   = 16'h0006;
localparam VCHIP_ALU_SHR   = 16'h0007;


string reg_names[7] = {
   "vers",
   "stat",
   "cmd",
   "cfg",
   "left",
   "right",
   "aout"
};

initial begin
  $dumpfile("dump.vcd");
  $dumpvars();
end

initial
begin
   clk <= 1'b0;
   while ( 1 )
   begin
      #5 clk <= 1'b1;
      #5 clk <= 1'b0;
   end
end
/////////////////////////////////////////////////////////////////////////////////////
// need to test all byte enables, do it with a for loop and a case statement
// test writing registers, test address 50 and ensure nothing is written to ALU_left,
// which is address 10
///////////////////////////////////////////////////////////////////////////////////// 
//reg [15:0] stim_array [4];
reg [15:0] bit_mask_array [4];

//aa stands for access array
// TODO: Not all bits are init 0, version register have init 1 at position 9 and 4.
int vers_reg_aa  [15:0] = {RO, RO, RO, RO, RO, RO, RO, RO, RO, RO, RO, RO, RO, RO, RO, RO};
int stat_reg_aa  [15:0] = {RO, RO, RO, RO, RO, RO, W1C,W1C,RO, RO, RO, RO, RO, RO, RO, RO};
int cmd_reg_aa   [15:0] = {W1C,RO, RO, RO, RO, RO, RO, RO, RO, RO, RO, RO, RW, RW, RW, RW};
int cfg_reg_aa   [15:0] = {RO, RO, RO, RO, RO, RO, RW, RW, RO, RO, RO, RO, RO, RO, RO, RO};
int left_reg_aa  [15:0] = {RW, RW, RW, RW, RW, RW, RW, RW, RW, RW, RW, RW, RW, RW, RW, RW};
int right_reg_aa [15:0] = {RW, RW, RW, RW, RW, RW, RW, RW, RW, RW, RW, RW, RW, RW, RW, RW};
int aout_reg_aa  [15:0] = {RO, RO, RO, RO, RO, RO, RO, RO, RO, RO, RO, RO, RO, RO, RO, RO};

// rv -- reset values.
bit vers_reg_rv  [15:0] = {0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0};
bit other_rv     [15:0] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

int my_access_array [0:6] [15:0] = {vers_reg_aa, stat_reg_aa, cmd_reg_aa, cfg_reg_aa, left_reg_aa, right_reg_aa, aout_reg_aa};
bit my_reset_val_array [0:6] [15:0] = {vers_reg_rv, other_rv, other_rv, other_rv, other_rv, other_rv, other_rv};
logic [15:0] my_wr_val = {16{1'b1}};
logic [15:0] my_reg_val = 16'h0;
logic [15:0] gen_exp_ret = 16'h0000;
logic [15:0] initial_val = 16'h0000;
logic [15:0] stim_array [0:3] = {16'hFFFF, 16'hAAAA, 16'h5555, 16'h0000};
int address_array [0:6] = {VCHIP_VER_ADDR, VCHIP_STA_ADDR, VCHIP_CMD_ADDR, VCHIP_CON_ADDR, VCHIP_ALU_LEFT_ADDR, VCHIP_ALU_RIGHT_ADDR, VCHIP_ALU_OUT_ADDR};
logic [15:0] normal_reg_values [0:6];
logic [15:0] error_reg_values [0:6];
logic [15:0] expvi_reg_values [0:6];
logic [15:0] scratch;

initial begin
   `CLEAR_ALL
   `CHIP_RESET



$display("calling finish");



$finish();
end 

verichip5 verichip (.clk           ( clk            ),    // system clock
                   .rst_b         ( rst_b          ),    // chip reset
                   .export_disable( export_disable ),    // disable features
                   .interrupt_1   ( interrupt_1    ),    // first interrupt
                   .interrupt_2   ( interrupt_2    ),    // second interrupt
 
                   .maroon        ( maroon         ),    // maroon state machine input
                   .gold          ( gold           ),    // gold state machine input

                   .chip_select   ( chip_select    ),    // target of r/w
                   .address       ( address        ),    // address bus
                   .byte_en       ( byte_en        ),    // write byte enables
                   .rw_           ( rw_            ),    // read/write
                   .data_in       ( data_in        ),    // data bus\

                   .data_out      ( data_out       ) );  // output data bus


endmodule
