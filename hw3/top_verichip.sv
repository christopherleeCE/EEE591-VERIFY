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
`define CHECK_VAL(val)                                      \
   $write("[data_out, expected] = [%h, %h]", data_out, val);\
   if ( data_out != val )                                   \
      $write(" : bad read @ time: %d",$time());  \
   $display();

`define CHECK_ALU_LEFT(val)                                      \
   $write("[verichip.alu_left, expected] = [%h, %h]", verichip.alu_left, val);   \
   if ( verichip.alu_left != val )                                               \
      $write(" : bad read @ time: %d",$time());                                  \
   $display();

`define CHECK_RW(addr,wval,exp_val,bytes,cs)    \
   `WRITE_REG(addr,wval,bytes,cs)         \
   `READ_REG(addr,cs)                     \
   //TODO can we comment out this debug output? \
   $display("data out is %h",data_out);   \
   `CHECK_VAL(exp_val)

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

`define CHIP_ERROR  \
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
   `CHECK_RW(VCHIP_ALU_LEFT_ADDR, 16'h1234, 16'h1234, 2'b11, 1'b1)     \
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

   $display("calling `CHIP_ERROR...");
   `CHIP_ERROR
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
         //$display("macro args: %h, %h", stim_array[i],stim_array[i] & bit_mask_array[_be]); 
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
         //$display("macro args: %h, %h", stim_array[i],stim_array[i] & bit_mask_array[_be]); 
         `CHECK_RW(VCHIP_ALU_LEFT_ADDR, stim_array[i], 16'h0, _be, 1'b0)
         `CHECK_ALU_LEFT(16'hBEAF)
      end
   end

   $display("\n \n \n");
   `DISPLAY_STATE 
   $display("time: %d", $time);

   export_disable <= 0;
   
   $display("calling `CHIP_ERROR...");
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
         //$display("macro args: %h, %h", stim_array[i],stim_array[i] & bit_mask_array[_be]); 
         `CHECK_RW(VCHIP_ALU_LEFT_ADDR, stim_array[i], 16'h0, _be, 1'b0)
         `CHECK_ALU_LEFT(16'hBEAF)
      end
      
   $display("\n \n \n");
   `DISPLAY_STATE   

   $display("calling `CHIP_EXP_VIO...");

   //in place of macro call
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
                           
      export_disable <= 1'b1; 
                           
      //write restricted cmd to command reg to go into error   
      //(even invalid commands are restricted)                 
      `WRITE_REG(VCHIP_CMD_ADDR, 16'h8008, 2'b11, 1'b1)                                   
      wait(clk == 1'b1); wait(clk == 1'b0); //min wait to see state change debug output   

   `DISPLAY_STATE

   for (int _be = 0; _be < 4; _be ++)
      for (int i = 0; i < 4; i++) begin
         //$display("macro args: %h, %h", stim_array[i],stim_array[i] & bit_mask_array[_be]); 
         `CHECK_RW(VCHIP_ALU_LEFT_ADDR, stim_array[i], 16'h0, _be, 1'b0)
         `CHECK_ALU_LEFT(16'h0)
      end


///////////////////////////////////////////////////////////////////////////////////// 
//cs = 1 + Aliasing; Check all register addresses that are not ALU left 7'h00-7'h7f
///////////////////////////////////////////////////////////////////////////////////// 
   export_disable <= 1'b0;
   $display("\n \n \n");
   $display("TESTING: cs = 1 + Aliasing in RESET state...");
   for (int aliasing_address = 0; aliasing_address <= 7'h7F; aliasing_address++) begin 
      if (aliasing_address == VCHIP_ALU_LEFT_ADDR) continue;
      for (int _be = 0; _be < 4; _be ++) begin
         for (int i = 0; i < 4; i++) begin
            // Reset the chip to ensure test independence.
            `CHIP_RESET
            `WRITE_REG(VCHIP_ALU_LEFT_ADDR, 16'hBEAF, 2'b11, 1'b1)
            // Check if aliasing occurs after writing to specified address.
            `WRITE_REG(aliasing_address[6:0], stim_array[i], _be, 1'b1)
            `CHECK_ALU_LEFT(16'hBEAF)
         end
      end
   end

   $display("\n \n \n");
   $display("TESTING: cs = 1 + Aliasing in NORMAL state...");
   for (int aliasing_address = 0; aliasing_address <= 7'h7F; aliasing_address++) begin 
      if (aliasing_address == VCHIP_ALU_LEFT_ADDR) continue;
      for (int _be = 0; _be < 4; _be ++) begin
         for (int i = 0; i < 4; i++) begin
            // Reset the chip to ensure test independence.
            `CHIP_RESET
            `WRITE_REG(VCHIP_ALU_LEFT_ADDR, 16'hBEAF, 2'b11, 1'b1)
            //go into normal from reset
            maroon <= 1'b0;     
            gold <= 1'b1;       
            wait(clk == 1'b1);  
            wait(clk == 1'b0);  
            // Check if aliasing occurs after writing to specified address.
            `WRITE_REG(aliasing_address[6:0], stim_array[i], _be, 1'b1)
            `CHECK_ALU_LEFT(16'hBEAF)
         end
      end
   end

   $display("\n \n \n");
   $display("TESTING: cs = 1 + Aliasing in ERROR state...");
   for (int aliasing_address = 0; aliasing_address <= 7'h7F; aliasing_address++) begin 
      if (aliasing_address == VCHIP_ALU_LEFT_ADDR) continue;
      for (int _be = 0; _be < 4; _be ++) begin
         for (int i = 0; i < 4; i++) begin
            
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
            //write bad command to command reg to go into error
            `WRITE_REG(VCHIP_CMD_ADDR, 16'h800C, 2'b11, 1'b1)
            wait(clk == 1'b1); wait(clk == 1'b0); //min wait to see state change debug output
 
            // Check if aliasing occurs after writing to specified address.
            `WRITE_REG(aliasing_address[6:0], stim_array[i], _be, 1'b1)
            `CHECK_ALU_LEFT(16'hBEAF)
         end
      end
   end

   $display("\n \n \n");
   $display("TESTING: cs = 1 + Aliasing in EXPORT VIOLATION state...");
   for (int aliasing_address = 0; aliasing_address <= 7'h7F; aliasing_address++) begin 
      if (aliasing_address == VCHIP_ALU_LEFT_ADDR) continue;
      for (int _be = 0; _be < 4; _be ++) begin
         for (int i = 0; i < 4; i++) begin
            // Reset the chip to ensure test independence.
            `CHIP_RESET
            `WRITE_REG(VCHIP_ALU_LEFT_ADDR, 16'hBEAF, 2'b11, 1'b1)
            // Go into normal state
            maroon <= 1'b0;
            gold <= 1'b1;
            wait(clk == 1'b1);
            wait(clk == 1'b0);
            // go to export violation
            export_disable <= 1'b1;
            `WRITE_REG(VCHIP_CMD_ADDR, 16'h8008, 2'b11, 1'b1)
            wait(clk == 1'b1); wait(clk == 1'b0); //min wait to see state change debug output 
            // Check if aliasing occurs after writing to specified address.
            `WRITE_REG(aliasing_address[6:0], stim_array[i], _be, 1'b1)
            `CHECK_ALU_LEFT(16'h0000)
         end
      end
   end
   export_disable <= 1'b0;
///////////////////////////////////////////////////////////////////////////////////// 
//cs = 0 + Aliasing
///////////////////////////////////////////////////////////////////////////////////// 
   export_disable <= 1'b0;
   $display("\n \n \n");
   $display("TESTING: cs = 0 + Aliasing in RESET state...");
   for (int aliasing_address = 0; aliasing_address <= 7'h7F; aliasing_address++) begin 
      if (aliasing_address == VCHIP_ALU_LEFT_ADDR) continue;
      for (int _be = 0; _be < 4; _be ++) begin
         for (int i = 0; i < 4; i++) begin
            // Reset the chip to ensure test independence.
            `CHIP_RESET
            `WRITE_REG(VCHIP_ALU_LEFT_ADDR, 16'hBEAF, 2'b11, 1'b1)
            // Check if aliasing occurs after writing to specified address.
            `WRITE_REG(aliasing_address[6:0], stim_array[i], _be, 1'b0)
            `CHECK_ALU_LEFT(16'hBEAF)
         end
      end
   end

   $display("\n \n \n");
   $display("TESTING: cs = 0 + Aliasing in NORMAL state...");
   for (int aliasing_address = 0; aliasing_address <= 7'h7F; aliasing_address++) begin 
      if (aliasing_address == VCHIP_ALU_LEFT_ADDR) continue;
      for (int _be = 0; _be < 4; _be ++) begin
         for (int i = 0; i < 4; i++) begin
            // Reset the chip to ensure test independence.
            `CHIP_RESET
            `WRITE_REG(VCHIP_ALU_LEFT_ADDR, 16'hBEAF, 2'b11, 1'b1)
            //go into normal from reset
            maroon <= 1'b0;     
            gold <= 1'b1;       
            wait(clk == 1'b1);  
            wait(clk == 1'b0);  
            // Check if aliasing occurs after writing to specified address.
            `WRITE_REG(aliasing_address[6:0], stim_array[i], _be, 1'b0)
            `CHECK_ALU_LEFT(16'hBEAF)
         end
      end
   end

   $display("\n \n \n");
   $display("TESTING: cs = 0 + Aliasing in ERROR state...");
   for (int aliasing_address = 0; aliasing_address <= 7'h7F; aliasing_address++) begin 
      if (aliasing_address == VCHIP_ALU_LEFT_ADDR) continue;
      for (int _be = 0; _be < 4; _be ++) begin
         for (int i = 0; i < 4; i++) begin
            
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
            //write bad command to command reg to go into error
            `WRITE_REG(VCHIP_CMD_ADDR, 16'h800C, 2'b11, 1'b1)
            wait(clk == 1'b1); wait(clk == 1'b0); //min wait to see state change debug output
 
            // Check if aliasing occurs after writing to specified address.
            `WRITE_REG(aliasing_address[6:0], stim_array[i], _be, 1'b0)
            `CHECK_ALU_LEFT(16'hBEAF)
         end
      end
   end

   $display("\n \n \n");
   $display("TESTING: cs = 0 + Aliasing in EXPORT VIOLATION state...");
   for (int aliasing_address = 0; aliasing_address <= 7'h7F; aliasing_address++) begin 
      if (aliasing_address == VCHIP_ALU_LEFT_ADDR) continue;
      for (int _be = 0; _be < 4; _be ++) begin
         for (int i = 0; i < 4; i++) begin
            // Reset the chip to ensure test independence.
            `CHIP_RESET
            `WRITE_REG(VCHIP_ALU_LEFT_ADDR, 16'hBEAF, 2'b11, 1'b1)
            // Go into normal state
            maroon <= 1'b0;
            gold <= 1'b1;
            wait(clk == 1'b1);
            wait(clk == 1'b0);
            // go to export violation
            export_disable <= 1'b1;
            `WRITE_REG(VCHIP_CMD_ADDR, 16'h8008, 2'b11, 1'b1)
            wait(clk == 1'b1); wait(clk == 1'b0); //min wait to see state change debug output 
            // Check if aliasing occurs after writing to specified address.
            `WRITE_REG(aliasing_address[6:0], stim_array[i], _be, 1'b0)
            `CHECK_ALU_LEFT(16'h0000)
         end
      end
   end
   export_disable <= 1'b0;


// Cs being 0 for all four states
// Aliased register addressed with cs = 0
// Aliased registers with cs = 1
// ##Change _cs to _bit_enable in the for loops because I totally called it the wrong thing 😎



   $finish;
end // initial begin

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
                   .data_in       ( data_in        ),    // data bus

                   .data_out      ( data_out       ) );  // output data bus

initial begin
  $dumpfile("dump.vcd");
  $dumpvars();
end
endmodule
