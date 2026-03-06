////////////////////////////
`timescale 1ns/1ps
// performed in 0 time

`define DISPLAY_STATE \
   $display("state: %h", verichip.state);

`define SET_WRITE(addr,val,bytes,cs)   \
   rw_ <= 1'b0;                     \
   chip_select <= cs;               \
   byte_en <= bytes;                \
   address <= addr;                 \
   data_in <= val;

// also in 0 time?
`define SET_READ(addr,cs)           \
   rw_ <= 1'b1;                     \
   chip_select <= cs;               \
   byte_en <= 2'b00;                \
   address <= addr;                 \
   data_in <= 16'h0;

// sets everything to "active"(?) values
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
`define CHECK_VAL(rd_val)                                      \
  assert (data_out == rd_val)                         \
    	$display("Read and Write Passed");							\
	else											\
		$display("CHECK VAL Er: Exp %h, Actual %h at %t", rd_val, data_out, $time());

`define CHECK_ALU_LEFT(val)                                      \
   // $write("[verichip.alu_left, expected] = [%h, %h]", verichip.alu_left, val);   \
   if ( verichip.alu_left != val )                                               \
   //    $write(" : bad read @ time: %d",$time());                                  \
   $display();

`define CHECK_RW(addr,wval,exp_val,bytes,cs)    \
   `WRITE_REG(addr,wval,bytes,cs)         \
   `READ_REG(addr,cs)                     \
   //TODO can we comment out this debug output? \
   $display("data out is %h",data_out);   \
   `CHECK_VAL(exp_val)

`define ALIASING_READ_CHECK(addr)	         \
	`WRITE_REG(addr, 16'hFFFF, 2'b11, 1'b1)	\
	for(int ii = 0; ii < 128; ++ii)	         \
	begin	                                    \
      //Do not overrite existing known good addresses/registers \
      if((ii != VCHIP_ALU_OUT_ADDR) && (ii != VCHIP_ALU_RIGHT_ADDR) && (ii != VCHIP_ALU_LEFT_ADDR) && (ii != VCHIP_CON_ADDR) && (ii != VCHIP_CMD_ADDR) && (ii != VCHIP_STA_ADDR) && (ii != VCHIP_VER_ADDR)) begin  \
         // read with cs high                \
         `READ_REG(ii, 1'b1)	               \
                                             \
         if (data_out != 16'h0000)	         \
         $display("Bad read: [data_out, expected] = [%h, %h]", data_out, 16'h0000); \
         // read with cs low                       \
         `READ_REG(addr, 1'b0)	                  \
                                                   \
         if (data_out != 16'h0000)	               \
         $display("Bad read: [data_out, expected] = [%h, %h]", data_out, 16'h0000); \
      end                                          \
   end                                             
    
`define ALIASING_WRITE_CHECK(addr,bytes = 2'b11,cs) //TODO need to havea  for loop for all byte enables\
for (int ii = 0 ; ii < 128 ; ++ii) begin  \
      // Do not check/overrite known good registers/addresses \
      if((ii != VCHIP_ALU_OUT_ADDR) && (ii != VCHIP_ALU_RIGHT_ADDR) && (ii != VCHIP_ALU_LEFT_ADDR) && (ii != VCHIP_CON_ADDR) && (ii != VCHIP_CMD_ADDR) && (ii != VCHIP_STA_ADDR) && (ii != VCHIP_VER_ADDR)) begin  \
         // Clear the address of interest write to it and validate correct write \
         `CHECK_RW(addr, 16'h0000, 16'h0000, 2'b11, 1'b1)	   \
         `WRITE_REG(ii, 16'hFFFF, bytes, cs)	                  \
         `READ_REG(addr, 1'b1)	                              \
                                                               \
         if (data_out != 16'h0000)	                           \
            $display("Bad read: [data_out, expected] = [%h, %h]", data_out, 16'h0000); \
                                                   \
         `WRITE_REG(ii, 16'hFFFF, bytes, cs)	      \
         `READ_REG(addr, 1'b1)	                  \
                                                   \
         if (data_out != 16'h0000)	            \
				$display("Bad read: [data_out, expected] = [%h, %h]", data_out, 16'h0000); \
                                                   \
      end	                                       \
end	                                             
   
// waits for the clock to be 0 and then asserts reset, then waits for 
// clk == 1 to deassert reset
`define CHIP_RESET                  \
   wait( clk == 1'b0 );             \
   rst_b <= 1'b0;                   \
   wait( clk == 1'b1 );             \
   rst_b <= 1'b1;

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

`define CHIP_ERROR(init_alu_lft_val)  \
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
   //set to a non-zero initial value                     \
   `CHECK_RW(VCHIP_ALU_LEFT_ADDR, init_alu_lft_val, init_alu_lft_val, 2'b11, 1'b1)     \
                                                         \
   //write bad command to command reg to go into error   \
   `WRITE_REG(VCHIP_CMD_ADDR, 16'h800C, 2'b11, 1'b1)     \
   wait(clk == 1'b1); wait(clk == 1'b0); //min wait to see state change debug output   \

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


module top_verichip ();

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
// test writing regisers, test address 50 and ensure nothing is written to ALU_left,
// which is address 10
///////////////////////////////////////////////////////////////////////////////////// 
reg [15:0] stim_array [4];
reg [15:0] bit_mask_array [4];


initial begin
   `CLEAR_ALL
   `CHIP_RESET

   stim_array = {16'hFFFF, 16'hAAAA, 16'h5555, 16'h0000};
   bit_mask_array = {16'h0000, 16'h00FF, 16'hFF00, 16'hFFFF};

///////////////////////////////////////////////////////////////////////////////////// 
//cs = 1
///////////////////////////////////////////////////////////////////////////////////// 
   $display("\n \n \n");
   `DISPLAY_STATE

   $display("calling `CHIP_RESET...");
   `CHIP_RESET
   `DISPLAY_STATE
   for (int _be = 0; _be < 4; _be ++) begin
      for (int i = 0; i < 4; i++) begin
         //$display("macro args: %h, %h", stim_array[i],stim_array[i] & bit_mask_array[_be]); 
         `CHECK_RW(VCHIP_ALU_LEFT_ADDR, stim_array[i], (stim_array[i] & bit_mask_array[_be]), _be, 1'b1)
      end
   end

   $display("\n \n \n");
   `DISPLAY_STATE

   $display("calling `CHIP_NORMAL...");
   `CHIP_NORMAL
   `DISPLAY_STATE
   for (int _be = 0; _be < 4; _be ++) begin
      for (int i = 0; i < 4; i++) begin
         //$display("macro args: %h, %h", stim_array[i],stim_array[i] & bit_mask_array[_be]); 
         `CHECK_RW(VCHIP_ALU_LEFT_ADDR, stim_array[i], (stim_array[i] & bit_mask_array[_be]), _be, 1'b1)
      end
   end

   $display("\n \n \n");
   `DISPLAY_STATE 

   $display("calling `CHIP_ER...");
   `CHIP_ERROR(16'h1234)
   `DISPLAY_STATE
   for (int _be = 0; _be < 4; _be ++)
      for (int i = 0; i < 4; i++) begin
         //$display("macro args: %h, %h", stim_array[i],stim_array[i] & bit_mask_array[_be]); 
         `CHECK_RW(VCHIP_ALU_LEFT_ADDR, stim_array[i], 16'h1234, _be, 1'b1)
      end
      
   $display("\n \n \n");
   `DISPLAY_STATE   

   $display("calling `CHIP_EXP_VIO...");
   `CHIP_EXP_VIO
   `DISPLAY_STATE
   for (int _be = 0; _be < 4; _be ++)
      for (int i = 0; i < 4; i++) begin
         //$display("macro args: %h, %h", stim_array[i],stim_array[i] & bit_mask_array[_be]); 
         `CHECK_RW(VCHIP_ALU_LEFT_ADDR, stim_array[i], 16'h0000, _be, 1'b1)
      end

   `CHIP_RESET


///////////////////////////////////////////////////////////////////////////////////// 
//cs = 0 -- Verichip is unselected; read all zeros
/////////////////////////////////////////////////////////////////////////////////////
   $display("\n \n \n");
   $display("cs %h", chip_select);   
   
   $display("\n \n \n");
   `DISPLAY_STATE

   $display("calling `CHIP_RESET...");
   `CHIP_RESET
   `DISPLAY_STATE

   `WRITE_REG(VCHIP_ALU_LEFT_ADDR, 16'hBEAF, 2'b11, 1'b1)
   `READ_REG(VCHIP_ALU_LEFT_ADDR, 1'b1)
   `CHECK_ALU_LEFT(16'hBEAF)

   for (int _be = 0; _be < 4; _be ++) begin
      for (int i = 0; i < 4; i++) begin 
         `CHECK_RW(VCHIP_ALU_LEFT_ADDR, stim_array[i], 16'h0, _be, 1'b0)
         `CHECK_ALU_LEFT(16'hBEAF)
      end
   end

   $display("\n \n \n");
   `DISPLAY_STATE

   $display("calling `CHIP_NORMAL...");
   `CHIP_NORMAL
   `DISPLAY_STATE

   `WRITE_REG(VCHIP_ALU_LEFT_ADDR, 16'hBEAF, 2'b11, 1'b1)
   `READ_REG(VCHIP_ALU_LEFT_ADDR, 1'b1)
   `CHECK_ALU_LEFT(16'hBEAF)

   for (int _be = 0; _be < 4; _be ++) begin
      for (int i = 0; i < 4; i++) begin
         `CHECK_RW(VCHIP_ALU_LEFT_ADDR, stim_array[i], 16'h0, _be, 1'b0)
         `CHECK_ALU_LEFT(16'hBEAF)
      end
   end

   $display("\n \n \n");
   `DISPLAY_STATE 
   $display("time: %d", $time);

   export_disable <= 0;
   
   $display("calling `CHIP_ER...");
   //not calling macro cus we need to get beaf into alu left, after reset occures
      wait(clk == 1'b0);  
      rst_b <= 1'b0;      
      wait(clk == 1'b1);  
      rst_b <= 1'b1;      
      wait(clk == 1'b0);  

      //go into normal from reset 
      maroon <= 1'b0;     
      gold <= 1'b1;       
      wait(clk == 1'b1);  
      wait(clk == 1'b0);  
                        
      //set to a non-zero initial value                     

      `WRITE_REG(VCHIP_ALU_LEFT_ADDR, 16'hBEAF, 2'b11, 1'b1)
      `READ_REG(VCHIP_ALU_LEFT_ADDR, 1'b1)
      `CHECK_ALU_LEFT(16'hBEAF)
                                                       
      //write bad command to command reg to go into error   
      `WRITE_REG(VCHIP_CMD_ADDR, 16'h800C, 2'b11, 1'b1)     
      wait(clk == 1'b1); wait(clk == 1'b0); //min wait to see state change debug output   
   
   `DISPLAY_STATE

   for (int _be = 0; _be < 4; _be ++)
      for (int i = 0; i < 4; i++) begin
         `CHECK_RW(VCHIP_ALU_LEFT_ADDR, stim_array[i], 16'h0, _be, 1'b0)
         `CHECK_ALU_LEFT(16'hBEAF)
      end
      
   $display("\n \n \n");
   `DISPLAY_STATE   


///////////////////////////////////////
// ALIAS TESTING- for all states
///////////////////////////////////////


// Testing Reset State for all byte_enables and chip select 0 & 1
for (int _be = 0; _be < 4; _be ++) begin
  `CHIP_RESET
  `DISPLAY_STATE
  `ALIASING_WRITE_CHECK(VCHIP_ALU_LEFT_ADDR,_be,1'b1) // cs high
  `ALIASING_WRITE_CHECK(VCHIP_ALU_LEFT_ADDR,_be,1'b0) // cs low
  `ALIASING_READ_CHECK(VCHIP_ALU_LEFT_ADDR) // read validate
end

// Testing Normal State for all byte_enables and chip select 0 & 1
for (int _be = 0; _be < 4; _be ++) begin
  `CHIP_NORMAL
  `DISPLAY_STATE
  `ALIASING_WRITE_CHECK(VCHIP_ALU_LEFT_ADDR,2'b11,1'b1) // cs high
  `ALIASING_WRITE_CHECK(VCHIP_ALU_LEFT_ADDR,2'b11,1'b0) // cs low
  `ALIASING_READ_CHECK(VCHIP_ALU_LEFT_ADDR) // read validate
end

// Testing Error State for all byte_enables and chip select 0 & 1
for (int _be = 0; _be < 4; _be ++) begin
  `CHIP_ERROR(16'h0000)
  `DISPLAY_STATE
  `ALIASING_WRITE_CHECK(VCHIP_ALU_LEFT_ADDR,2'b11,1'b1) // cs high
  `ALIASING_WRITE_CHECK(VCHIP_ALU_LEFT_ADDR,2'b11,1'b0) // cs low
  `ALIASING_READ_CHECK(VCHIP_ALU_LEFT_ADDR) // read validate
end

// Testing Export Violation State for all byte_enables and chip select 0 & 1
for (int _be = 0; _be < 4; _be ++) begin
  `CHIP_EXP_VIO
  `DISPLAY_STATE
  `ALIASING_WRITE_CHECK(VCHIP_ALU_LEFT_ADDR,2'b11,1'b1) // cs high
  `ALIASING_WRITE_CHECK(VCHIP_ALU_LEFT_ADDR,2'b11,1'b0) // cs low
  `ALIASING_READ_CHECK(VCHIP_ALU_LEFT_ADDR) // read validate
end

   $finish();
end 

verichip verichip (.clk           ( clk            ),    // system clock
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
