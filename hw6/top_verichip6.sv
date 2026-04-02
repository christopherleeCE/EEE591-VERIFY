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

`define CHECK_STATE(expected_state) \
   `READ_REG(VCHIP_STA_ADDR,1)      \
   if(data_out[3:0] != expected_state) begin   \
         $write("Bad state, expected state: %p, actual: ", expected_state);    \
   end if(data_out[3:0] == 4'h0) begin       \
         $display("reset");       \
   end else if(data_out[3:0] == 4'h1) begin       \
         $display("normal");       \
   end else if(data_out[3:0] == 4'h2) begin       \
         $display("err0r");       \
   end else if(data_out[3:0] == 4'h8) begin       \
         $display("expvi");       \
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
`define ALIASING_WRITE_CHECK(addr,bytes = 2'b11,cs,exp_val) \
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
   out_reg = 16'h0210;     \
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
   maroon <= 1'b0;     \
   gold <= 1'b0;       \
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

   // STATE_MASTERRR -- Controls state of the machine
   // exp_state = Expected state
   // M = Maroon, G = Gold signals
   // E = Boolean to generate export violation signal
   // B = Boolean to generate bad command signal
   `define STATE_MASTER(exp_state,M,G,E,B) \
      if(E) begin `GEN_EXP_VIO end \
      if(B) begin `GEN_BAD_CMD end \
      maroon = M;     \
      gold = G;       \
     //`DISPLAY_STATE    \
     wait(clk == 0); wait(clk == 1); wait(clk == 0); \
     maroon = 0; gold = 0;                            \
     `CHECK_STATE(exp_state)

   //called on neg edge, appears on next pos edge
   `define GEN_BAD_CMD \
   `WRITE_REG(VCHIP_CMD_ADDR, 16'h800C, 2'b11, 1'b1)     \
   wait(clk == 1'b1); wait(clk == 1'b0); //min wait to see state change debug output   


   //on posedge, not on the next posedge, but the one after
   `define GEN_EXP_VIO  \
   //assert exp disable, wait 2clk to ensure its in reg  \
   export_disable <= 1'b1;                            \
   wait(clk == 0); wait(clk == 1); wait(clk == 0);    \
                                                      \
   //get into expvio                                  \
   `WRITE_REG(VCHIP_CMD_ADDR, 16'h8004, 2'b11, 1'b1)  \
   wait(clk == 0); wait(clk == 1); wait(clk == 0);    \
                                                      \
   `READ_REG(VCHIP_STA_ADDR, 1'b1)                    \
   $display("expvi, data_out: %h", data_out);

   `define LI_AOUT(val) \
      `CHECK_RW(VCHIP_ALU_LEFT_ADDR,(val-16'h2),(val-16'h2),2'b11,1'b1)           \
      `CHECK_RW(VCHIP_ALU_RIGHT_ADDR,16'h0002,16'h0002,2'b11,1'b1)      \
      if ((verichip.alu_left == verichip.alu_right) || (verichip.alu_left == verichip.alu_out) || (verichip.alu_right == verichip.alu_out)) begin\
      $display("alu values matching before a command alu_left = %h, alu_right = %h command alu_out = %h",verichip.alu_left,verichip.alu_right,verichip.alu_out); \
      end  \
      `CHECK_RW(VCHIP_CMD_ADDR,16'h8001,16'h0001,2'b11,1'b1)  \
      `READ_REG(VCHIP_ALU_OUT_ADDR,1'b1)                          \
      `CHECK_VAL(val)

   `define DRIVE_CMD(left_val,right_val,opcode,expval_l, expval_r, expval_o, exp_state) \
      `CHECK_RW(VCHIP_ALU_LEFT_ADDR,left_val,left_val,2'b11,1'b1)           \
      `CHECK_RW(VCHIP_ALU_RIGHT_ADDR,right_val,right_val,2'b11,1'b1)      \
      if ((verichip.alu_left == verichip.alu_right) || (verichip.alu_left == verichip.alu_out) || (verichip.alu_right == verichip.alu_out)) begin\
      $display("alu values matching before a command alu_left = %h, alu_right = %h command alu_out = %h",verichip.alu_left,verichip.alu_right,verichip.alu_out); \
      end  \
      `CHECK_RW(VCHIP_CMD_ADDR,opcode,(opcode-16'h8000),2'b11,1'b1)  \
      wait(clk == 0); wait(clk == 1); wait(clk == 0); wait(clk == 1); wait(clk == 0); \
                                                               \
                                                                  \
      `READ_REG(VCHIP_ALU_LEFT_ADDR,1'b1)                          \
      `CHECK_VAL(expval_l)                                          \
                                                                     \
      `READ_REG(VCHIP_ALU_RIGHT_ADDR,1'b1)                          \
      `CHECK_VAL(expval_r)                                          \
                                                                     \
      `READ_REG(VCHIP_ALU_OUT_ADDR,1'b1)                          \
      `CHECK_VAL(expval_o)                                          \
                                                                  \
      `CHECK_STATE(exp_state)                                     \

   `define DRIVE_CMD_NO_OPSUB(left_val,right_val,opcode,expval_l, expval_r, expval_o, exp_state) \
      `CHECK_RW(VCHIP_ALU_LEFT_ADDR,left_val,left_val,2'b11,1'b1)           \
      `CHECK_RW(VCHIP_ALU_RIGHT_ADDR,right_val,right_val,2'b11,1'b1)      \
      `CHECK_RW(VCHIP_CMD_ADDR,opcode,opcode,2'b11,1'b1)  \
      wait(clk == 0); wait(clk == 1); wait(clk == 0); wait(clk == 1); wait(clk == 0); \
                                                               \
                                                                  \
      `READ_REG(VCHIP_ALU_LEFT_ADDR,1'b1)                          \
      `CHECK_VAL(expval_l)                                          \
                                                                     \
      `READ_REG(VCHIP_ALU_RIGHT_ADDR,1'b1)                          \
      `CHECK_VAL(expval_r)                                          \
                                                                     \
      `READ_REG(VCHIP_ALU_OUT_ADDR,1'b1)                          \
      `CHECK_VAL(expval_o)                                          \
                                                                  \
      `CHECK_STATE(exp_state)                                     \



module top_verichip6 ();



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

logic pp = 0;

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

initial begin

   export_disable = 0;

   $display("Begining of rst section");

   `CLEAR_ALL
   `CHIP_RESET
   `DISPLAY_STATE

   // <RESET STATE> currently gets "reset state check failed: 0000000011111111"
      //////////////////////////////////////////////////////////
      //ALU NOP
      ///////////////////////////////////////////////////////////
      $display("NOP");
     // `LI_AOUT(16'h0001)
      `DRIVE_CMD(16'h0001,16'h5555,16'h8000,16'h0001,16'h5555,16'h0000,4'h0) // Bad read: [data_out, expected] = [0001, 0000]
 // `LI_AOUT(16'h0001)
     `DRIVE_CMD(16'hFFFF,16'hAAAA,16'h8000,16'hFFFF,16'hAAAA,16'h0000,4'h0)
 // `LI_AOUT(16'h0001)
     `DRIVE_CMD(16'h5555,16'hFFFF,16'h8000,16'h5555,16'hFFFF,16'h0000,4'h0) // Bad read: [data_out, expected] = [0001, 0000]
 // `LI_AOUT(16'h0001)
      `DRIVE_CMD(16'hAAAA,16'h0001,16'h8000,16'hAAAA,16'h0001,16'h0000,4'h0)
      `DISPLAY_STATE

      //////////////////////////////////////////////////////////
      //ALU ADD
      ///////////////////////////////////////////////////////////
      $display("ADD");
  //`LI_AOUT(16'h0001)

      `DRIVE_CMD(16'h0001,16'h5555,16'h8001,16'h0001,16'h5555,16'h0000,4'h0)
     // `LI_AOUT(16'h0000)
      `DRIVE_CMD(16'hFFFF,16'hAAAA,16'h8001,16'hFFFF,16'hAAAA,16'h0000,4'h0)
    //  `LI_AOUT(16'h0000)
      `DRIVE_CMD(16'h5555,16'hFFFF,16'h8001,16'h5555,16'hFFFF,16'h0000,4'h0)
     // `LI_AOUT(16'h0000)
      `DRIVE_CMD(16'hAAAA,16'h0001,16'h8001,16'hAAAA,16'h0001,16'h0000,4'h0)
      `DISPLAY_STATE

      //////////////////////////////////////////////////////////
      //ALU SUB
      ///////////////////////////////////////////////////////////
      $display("SUB");
     // `LI_AOUT(16'h0000)
      `DRIVE_CMD(16'h5555,16'h0001,16'h8002,16'h5555,16'h0001,16'h0000,4'h0)
     // `LI_AOUT(16'h0000)
      `DRIVE_CMD(16'hFFFF,16'hAAAA,16'h8002,16'hFFFF,16'hAAAA,16'h0000,4'h0)
     // `LI_AOUT(16'h0000)
      `DRIVE_CMD(16'h0001,16'hFFFF,16'h8002,16'h0001,16'hFFFF,16'h0000,4'h0)
     // `LI_AOUT(16'h0000)
      `DRIVE_CMD(16'hAAAA,16'h5555,16'h8002,16'hAAAA,16'h5555,16'h0000,4'h0)
      `DISPLAY_STATE

      //////////////////////////////////////////////////////////
      //ALU MOVE LEFT
      ///////////////////////////////////////////////////////////
      $display("MOVE LEFT");
     // `LI_AOUT(16'h0000)
      `DRIVE_CMD(16'h5555,16'h0001,16'h8003,16'h5555,16'h0001,16'h0000,4'h0)
     // `LI_AOUT(16'h0000)
      `DRIVE_CMD(16'hFFFF,16'hAAAA,16'h8003,16'hFFFF,16'hAAAA,16'h0000,4'h0)
     // `LI_AOUT(16'h0000)
      `DRIVE_CMD(16'h0001,16'hFFFF,16'h8003,16'h0001,16'hFFFF,16'h0000,4'h0)
     // `LI_AOUT(16'h0000)
      `DRIVE_CMD(16'hAAAA,16'h5555,16'h8003,16'hAAAA,16'h5555,16'h0000,4'h0)
      `DISPLAY_STATE

      //////////////////////////////////////////////////////////
      //ALU MOVE RIGHT
      ///////////////////////////////////////////////////////////
      $display("MOVE RIGHT");
     // `LI_AOUT(16'h0000)
      `DRIVE_CMD(16'h5555,16'h0001,16'h8004,16'h5555,16'h0001,16'h0000,4'h0)
     // `LI_AOUT(16'h0000)
      `DRIVE_CMD(16'hFFFF,16'hAAAA,16'h8004,16'hFFFF,16'hAAAA,16'h0000,4'h0)
     // `LI_AOUT(16'h0000)
      `DRIVE_CMD(16'h0001,16'hFFFF,16'h8004,16'h0001,16'hFFFF,16'h0000,4'h0)
     // `LI_AOUT(16'h0000)
      `DRIVE_CMD(16'hAAAA,16'h5555,16'h8004,16'hAAAA,16'h5555,16'h0000,4'h0)
      `DISPLAY_STATE

      //////////////////////////////////////////////////////////
      //SWAP
      ///////////////////////////////////////////////////////////
      $display("SWAP");
     // `LI_AOUT(16'h0000)
      `DRIVE_CMD(16'h5555,16'h0001,16'h8005,16'h5555,16'h0001,16'h0000,4'h0)
     // `LI_AOUT(16'h0000)
      `DRIVE_CMD(16'hFFFF,16'hAAAA,16'h8005,16'hFFFF,16'hAAAA,16'h0000,4'h0)
      //`LI_AOUT(16'h0000)
      `DRIVE_CMD(16'h0001,16'hFFFF,16'h8005,16'h0001,16'hFFFF,16'h0000,4'h0)
      //`LI_AOUT(16'h0000)
      `DRIVE_CMD(16'hAAAA,16'h5555,16'h8005,16'hAAAA,16'h5555,16'h0000,4'h0)
      `DISPLAY_STATE

      //////////////////////////////////////////////////////////
      //ALU SHIFT LEFT 
      ///////////////////////////////////////////////////////////
      $display("SHIFT LEFT");
     // `LI_AOUT(16'h0000)
      `DRIVE_CMD(16'h5555,16'h0001,16'h8006,16'h5555,16'h0001,16'h0000,4'h0)
     // `LI_AOUT(16'h0000)
      `DRIVE_CMD(16'hFFFF,16'hAAAA,16'h8006,16'hFFFF,16'hAAAA,16'h0000,4'h0)
     // `LI_AOUT(16'h0000)
      `DRIVE_CMD(16'h0001,16'hFFFF,16'h8006,16'h0001,16'hFFFF,16'h0000,4'h0)
     // `LI_AOUT(16'h0000)
      `DRIVE_CMD(16'hAAAA,16'h0001,16'h8006,16'hAAAA,16'h0001,16'h0000,4'h0)
      `DISPLAY_STATE

      //////////////////////////////////////////////////////////
      //ALU SHIFT RIGHT 
      ///////////////////////////////////////////////////////////
      $display("SHIFT RIGHT");
    //  `LI_AOUT(16'h0000)
     `DRIVE_CMD(16'h5555,16'h0001,16'h8007,16'h5555,16'h0001,16'h0000,4'h0)
     // `LI_AOUT(16'h0000)
      `DRIVE_CMD(16'hFFFF,16'hAAAA,16'h8007,16'hFFFF,16'hAAAA,16'h0000,4'h0)
    //  `LI_AOUT(16'h0000)
      `DRIVE_CMD(16'h0001,16'hFFFF,16'h8007,16'h0001,16'hFFFF,16'h0000,4'h0)
    //  `LI_AOUT(16'h0000)
      `DRIVE_CMD(16'hAAAA,16'h0001,16'h8007,16'hAAAA,16'h0001,16'h0000,4'h0)
      `DISPLAY_STATE


      // TODO have bad command with export_deisable = 1 as well
      //////////////////////////////////////////////////////////
      // bad command
      ///////////////////////////////////////////////////////////
      $display("BAD CMD");
      for (logic [15:0] i =8; i <16; i++ ) begin
         `CHIP_RESET
      //   `LI_AOUT(16'h0000)
         `DRIVE_CMD(16'h0001,16'h5555,(16'h8000 + i),16'h0001,16'h5555,16'h0000,4'h0)
         `CHIP_RESET
     //    `LI_AOUT(16'h0000)
         `DRIVE_CMD(16'hFFFF,16'hAAAA,(16'h8000 + i),16'hFFFF,16'hAAAA,16'h0000,4'h0)
         `CHIP_RESET
     //    `LI_AOUT(16'h0000)
         `DRIVE_CMD(16'h0001,16'hFFFF,(16'h8000 + i),16'h0001,16'hFFFF,16'h0000,4'h0)
         `CHIP_RESET
     //    `LI_AOUT(16'h0000)
         `DRIVE_CMD(16'hAAAA,16'h0001,(16'h8000 + i),16'hAAAA,16'h0001,16'h0000,4'h0)
      end

/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////

   $display("Begining of nrm section");

   `CLEAR_ALL
   `CHIP_RESET
   `CHIP_NORMAL
   `DISPLAY_STATE

   for (logic [1:0] i = 0; i < 2; i++) begin
      $display ("i is %d", i);
      if (i == 0) begin
         export_disable <= 1'b0;
      end
      else begin
         export_disable <= 1'b1;
      end
   
   // <NORMAL STATE>
      //////////////////////////////////////////////////////////
      //ALU NOP
      ///////////////////////////////////////////////////////////
      $display("NOP");
      `CHIP_NORMAL
      `LI_AOUT(16'h0001)
      `DRIVE_CMD(16'h0000,16'h5555,16'h8000,16'h0000,16'h5555,((export_disable) ? (16'h0001) : (16'h0001) ),4'h1)
      `CHIP_NORMAL
      `LI_AOUT(16'h0001)
      $display("1");
      `DRIVE_CMD(16'hFFFF,16'hAAAA,16'h8000,16'hFFFF,16'hAAAA,((export_disable) ? (16'h0001) : (16'h0001) ),4'h1)
      `CHIP_NORMAL
      `LI_AOUT(16'h0001)
      $display("2");
      `DRIVE_CMD(16'h5555,16'hFFFF,16'h8000,16'h5555,16'hFFFF,((export_disable) ? (16'h0001) : (16'h0001) ),4'h1)
      `CHIP_NORMAL
      `LI_AOUT(16'h0001)
      `DRIVE_CMD(16'hAAAA,16'h0000,16'h8000,16'hAAAA,16'h0000,((export_disable) ? (16'h0001) : (16'h0001) ),4'h1)
      `CHIP_NORMAL
      `DISPLAY_STATE

      //////////////////////////////////////////////////////////
      //ALU ADD
      ///////////////////////////////////////////////////////////
      $display("ADD");
      if (export_disable == 1) begin
         pp = 1;
      end 
      `CHIP_NORMAL
      `LI_AOUT(16'h0001)
      `DRIVE_CMD(16'h0000,16'h5555,16'h8001,16'h0000,16'h5555,((export_disable) ? (16'h5555) : (16'h5555) ),4'h1)
      `CHIP_NORMAL
      `LI_AOUT(16'h0001)
      `CHIP_NORMAL
      `DRIVE_CMD(16'hFFFF,16'hAAAA,16'h8001,16'hFFFF,16'hAAAA,((export_disable) ? (16'hAAA9) : (16'hAAA9) ),4'h1)
      `DISPLAY_STATE
      `CHIP_NORMAL
      `LI_AOUT(16'h0001)
      `DRIVE_CMD(16'h5555,16'hFFFF,16'h8001,16'h5555,16'hFFFF,((export_disable) ? (16'h5554) : (16'h5554) ),4'h1)
      `CHIP_NORMAL
      `LI_AOUT(16'h0001)
      `DRIVE_CMD(16'hAAAA,16'h0000,16'h8001,16'hAAAA,16'h0000,((export_disable) ? (16'hAAAA) : (16'hAAAA) ),4'h1)
      `CHIP_NORMAL
      `DISPLAY_STATE
      `DRIVE_CMD(16'h7FFF,16'h0002,16'h8001,16'h7FFF,16'h0002,((export_disable) ? (16'h8001) : (16'h8001) ),4'h1)
      `DISPLAY_STATE
      `CHIP_NORMAL

      //////////////////////////////////////////////////////////
      //ALU SUB NORMAL
      ///////////////////////////////////////////////////////////
      $display("SUB");
      // `LI_AOUT(16'h0001)
      `READ_REG(VCHIP_ALU_OUT_ADDR, 1'b1)
      `DRIVE_CMD(16'h5555,16'h0001,16'h8002,16'h5555,16'h0001,((export_disable) ? (16'h5554) : (16'h5554) ),4'h1)
      `CHIP_NORMAL
      `LI_AOUT(16'h0001)
      `DRIVE_CMD(16'hFFFF,16'hAAAA,16'h8002,16'hFFFF,16'hAAAA,((export_disable) ? (16'h5555) : (16'h5555) ),4'h1)
      `CHIP_NORMAL
      // `LI_AOUT(16'h0001)
      `DRIVE_CMD(16'h0005,16'hFFFF,16'h8002,16'h0005,16'hFFFF,((export_disable) ? (16'h0006) : (16'h0006) ),4'h1)
      `DISPLAY_STATE
      `CHIP_NORMAL
      // `LI_AOUT(16'h0001)
      `DRIVE_CMD(16'hAAAA,16'h5555,16'h8002,16'hAAAA,16'h0000,((export_disable) ? (16'hAAAA) : (16'hAAAA) ),4'h1)
      `CHIP_NORMAL
      `DISPLAY_STATE
      `CHIP_NORMAL

      //////////////////////////////////////////////////////////
      //ALU MOVE LEFT NORMAL
      ///////////////////////////////////////////////////////////
      $display("MOVE LEFT");
      `LI_AOUT(16'h0000)
      `DRIVE_CMD(16'h5555,16'h0001,16'h8003,16'h0020,16'h0001,((export_disable) ? (16'h0000) : (16'h0020) ),4'h1)
      `CHIP_NORMAL
      `LI_AOUT(16'h0000)
      `DRIVE_CMD(16'hFFFF,16'hAAAA,16'h8003,16'hAAAA,16'hAAAA,((export_disable) ? (16'h0000) : (16'hAAAA) ),4'h1)
      `CHIP_NORMAL
      `LI_AOUT(16'h0000)
      `DRIVE_CMD(16'h0001,16'hFFFF,16'h8003,16'hAAAA,16'hFFFF,((export_disable) ? (16'h0000) : (16'hAAAA) ),4'h1)
      `CHIP_NORMAL
      `LI_AOUT(16'h0000)
      `DRIVE_CMD(16'hAAAA,16'h5555,16'h8003,16'hFFFF,16'h5555,((export_disable) ? (16'h0000) : (16'hFFFF) ),4'h1)
      `CHIP_NORMAL
      `DISPLAY_STATE

      //////////////////////////////////////////////////////////
      //ALU MOVE RIGHT
      ///////////////////////////////////////////////////////////
      $display("MOVE RIGHT");
      `LI_AOUT(16'h0001)
      `DRIVE_CMD(16'h5555,16'h0000,16'h8004,16'h5555,16'h0020,((export_disable) ? (16'h0000) : (16'h0020) ),4'h1)
      `CHIP_NORMAL
      `LI_AOUT(16'h0001)
      `DRIVE_CMD(16'hFFFF,16'hAAAA,16'h8004,16'hFFFF,16'hAAAA,((export_disable) ? (16'h0000) : (16'hAAAA) ),4'h1)
      `CHIP_NORMAL
      `LI_AOUT(16'h0001)
      `DRIVE_CMD(16'h0000,16'hFFFF,16'h8004,16'h0000,16'hAAAA,((export_disable) ? (16'h0000) : (16'hAAAA) ),4'h1)
      `CHIP_NORMAL
      `LI_AOUT(16'h0001)
      `DRIVE_CMD(16'hAAAA,16'h5555,16'h8004,16'hAAAA,16'hFFFF,((export_disable) ? (16'h0000) : (16'hFFFF) ),4'h1)
      `CHIP_NORMAL
      `DISPLAY_STATE

      //////////////////////////////////////////////////////////
      //SWAP
      ///////////////////////////////////////////////////////////
      $display("SWAP");;
      `LI_AOUT(16'h0001)
      `DRIVE_CMD(16'h5555,16'h0000,16'h8005,16'h0001,16'h5555,((export_disable) ? (16'h0000) : (16'h0020) ),4'h1)
      `CHIP_NORMAL
      `LI_AOUT(16'h0001)
      `DRIVE_CMD(16'hFFFF,16'hAAAA,16'h8005,16'hAAAA,16'hFFFF,((export_disable) ? (16'h0000) : (16'hAAAA) ),4'h1)
      `CHIP_NORMAL
      `LI_AOUT(16'h0001)
      `DRIVE_CMD(16'h0000,16'hFFFF,16'h8005,16'hFFFF,16'h0000,((export_disable) ? (16'h0000) : (16'hAAAA) ),4'h1)
      `CHIP_NORMAL
      `LI_AOUT(16'h0001)
      `DRIVE_CMD(16'hAAAA,16'h5555,16'h8005,16'h5555,16'hAAAA,((export_disable) ? (16'h0000) : (16'hFFFF) ),4'h1)
      `CHIP_NORMAL
      `DISPLAY_STATE

      //////////////////////////////////////////////////////////
      //ALU SHIFT LEFT 
      ///////////////////////////////////////////////////////////
      $display("SHIFT LEFT");
      `LI_AOUT(16'h0001)
      `DRIVE_CMD(16'h5555,16'h0000,16'h8006,16'h5555,16'h0000,((export_disable) ? (16'h0000) : (16'h5555) ),4'h1)
      `CHIP_NORMAL
      `LI_AOUT(16'h0001)
      `DRIVE_CMD(16'hFFFF,16'hAAAA,16'h8006,16'hFFFF,16'hAAAA,((export_disable) ? (16'h0000) : ((16'hFFFF) )<<16'hAAAA),4'h1)
      `CHIP_NORMAL
      `LI_AOUT(16'h0001)
      `DRIVE_CMD(16'h0000,16'hFFFF,16'h8006,16'h0000,16'hFFFF,((export_disable) ? (16'h0000) : ((16'h0000) )<<16'hFFFF),4'h1)
      `CHIP_NORMAL
      `LI_AOUT(16'h0001)
      `DRIVE_CMD(16'hAAAA,15'h5555,16'h8006,16'hAAAA,16'h0001,((export_disable) ? (16'h0000) : ((16'hAAAA) )<<16'h0001),4'h1)
      `CHIP_NORMAL
      `DISPLAY_STATE

      //////////////////////////////////////////////////////////
      //ALU SHIFT RIGHT 
      ///////////////////////////////////////////////////////////
      $display("SHIFT RIGHT");
      `LI_AOUT(16'h0001)
      `DRIVE_CMD(16'h5555,16'h0000,16'h8007,16'h5555,16'h0000,((export_disable) ? (16'h0000) : (16'h5555) ),4'h1)
      `CHIP_NORMAL
      `LI_AOUT(16'h0001)
      `DRIVE_CMD(16'hFFFF,16'hAAAA,16'h8007,16'hFFFF,16'hAAAA,((export_disable) ? (16'h0000) : ((16'hFFFF) )>>16'hAAAA),4'h1)
      `CHIP_NORMAL
      `LI_AOUT(16'h0001)
      `DRIVE_CMD(16'h0000,16'hFFFF,16'h8007,16'h0000,16'hFFFF,((export_disable) ? (16'h0000) : ((16'h0000) )>>16'hFFFF),4'h1)
      `CHIP_NORMAL
      `LI_AOUT(16'h0001)
      `DRIVE_CMD(16'hAAAA,16'h5555,16'h8007,16'hAAAA,16'h0001,((export_disable) ? (16'h0000) : ((16'hAAAA) )>>16'h0001),4'h1)
      `CHIP_NORMAL
      `DISPLAY_STATE
      
   

   // TODO have bad command with export_deisable = 1 as well
   //////////////////////////////////////////////////////////
   // bad command
   ///////////////////////////////////////////////////////////
   $display("BAD CMD");
   for (logic [15:0] i =8; i <16; i++ ) begin
      `CHIP_NORMAL
      `LI_AOUT(16'h0001)
      `DRIVE_CMD(16'h0000,16'h5555,(16'h8000 + i),((export_disable) ? (16'h0000) : (16'h0001) ),16'h5555,16'h0020,4'h2)
      `CHIP_NORMAL
      `LI_AOUT(16'h0001)
      `DRIVE_CMD(16'hFFFF,16'hAAAA,(16'h8000 + i),((export_disable) ? (16'h0000) : (16'hFFFF) ),16'hAAAA,16'hAAAA,4'h2)
      `CHIP_NORMAL
      `LI_AOUT(16'hAAAA)
      `DRIVE_CMD(16'h0000,16'hFFFF,(16'h8000 + i),((export_disable) ? (16'h0000) : (16'h0000) ),16'hFFFF,16'hAAAA,4'h2)
      `CHIP_NORMAL
      `LI_AOUT(16'hFFFF)
      `DRIVE_CMD(16'hAAAA,16'h0001,(16'h8000 + i),((export_disable) ? (16'h0000) : (16'hAAAA) ),16'h5555,16'hFFFF,4'h2)
   end

   
   ////////////////////////////////////////////////////////
  // valid = 0
   /////////////////////////////////////////////////////////
   $display("valid = 0");
   for (logic [15:0] i = 0 ; i <16; i++ ) begin
      `CHIP_NORMAL
      `LI_AOUT(16'h0020)
      `DRIVE_CMD_NO_OPSUB(16'h0000,16'h5555,(16'h0000 + i),16'h0000,16'h5555,16'h0020,4'h1)
      `DISPLAY_STATE

      `CHIP_NORMAL
      `LI_AOUT(16'hAAAA)
      `DRIVE_CMD_NO_OPSUB(16'hFFFF,16'hAAAA,(16'h0000 + i),16'hFFFF,16'hAAAA,16'hAAAA,4'h1)
      `DISPLAY_STATE

      `CHIP_NORMAL
      `LI_AOUT(16'hAAAA)
      `DRIVE_CMD_NO_OPSUB(16'h0000,16'hFFFF,(16'h0000 + i),16'h0000,16'hFFFF,16'hAAAA,4'h1)
      `DISPLAY_STATE

      `CHIP_NORMAL
      `LI_AOUT(16'hFFFF)
      `DRIVE_CMD_NO_OPSUB(16'hAAAA,16'h0000,(16'h0000 + i),16'hAAAA,16'h0000,16'hFFFF,4'h1)
      `DISPLAY_STATE
   end

end

   wait(clk == 1'b0);   // MUST LEAVE SO GRADING WORKS!
   wait(clk == 1'b1);
   wait(clk == 1'b0);

   $finish();

end 

verichip6 verichip (.clk          ( clk            ),    // system clock
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