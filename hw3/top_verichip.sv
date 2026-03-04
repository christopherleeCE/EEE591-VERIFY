`timescale 1ns/1ps

//TODO i dont even think maroon and gold are declared, issue?

//there is another way of added "branching" in the macro, looks like this
//`define DO_0  $display("Code A");
//`define DO_1  $display("Code B");
//
//`define DO(x) `DO_``x
//
//i opted just to use if statements cus millman doesnt hate them afaink
//
//yes you need a \ at EVERY LINE, even if the line is just a newline,
//and yes, you need the backlash after the comment, you can have it before
//quick tip, use ':set list' to show newlines where newlines are, they will be
//indicated with a '$', so you can tell if there is whitespace after ur \
//aruguably i shouldve made a set_reset macro, and set normal macro, however
//looking at it now i find that this is more readable anyway imo (to me at least)
`define CHANGE_STATE(state)    \
    if(state == 16'h0) begin    \
                            \
        wait(clk == 1'b0);  \
        rst_b <= 1'b0;      \
        wait(clk == 1'b1);  \
        rst_b <= 1'b1;      \
        wait(clk == 1'b0); //idk *shrug \
                            \
    end else if(state == 16'h1) begin   \
                            \
        //go into reset     \
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
    end else if(state == 16'h2) begin   \
                            \
        //go into reset     \
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
        //go into error from normal                 \
        //either for bad cmd or get it organically  \
                                        \
    end else if(state == 16'h8) begin   \
                            \
        //go into reset     \
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
        //go into expviol from normal                                                   \
        //either force an intrupt or sumthin, or get it organically, need timing waits  \
                            \
    end else begin  \
                        \
        $error("bad macro call, CHANGE_STATE(%h)", state); \
                        \
    end \



`define DISPLAY_STATE \
    $display("state: %h", verichip.state); 


// performed in 0 time
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
   wait(clk == 1'b0); \
   `SET_READ(addr,cs) \
   wait(clk == 1'b1); \
   wait(clk == 1'b0);

//give it a value, if the data_out on the data bus is not that value, throw an error
`define CHECK_VAL(val)              \
   if ( data_out != val )           \
       $display("bad read, got %h but expected %h at %t",data_out,val,$time());

//TODO should be include check_val() here too? the name kinda implies that it does some checking, but from what i see it only gets the read value onto the data_out
`define CHECK_RW(addr,wval,bytes,cs)    \
   `WRITE_REG(addr,wval,bytes,cs)            \
   `READ_REG(addr,cs)

// waits for the clock to be 0 and then asserts reset, then waits for 
// clk == 1 to deassert reset
`define CHIP_RESET                  \
   wait( clk == 1'b0 );             \
   rst_b <= 1'b0;                   \
   wait( clk == 1'b1 );             \
   rst_b <= 1'b1;

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
// wait for the
///////////////////////////////////////////////////////////////////////////////////// 
initial
begin
    `CLEAR_ALL
    `CHIP_RESET
#10;
    //you can delete the $time outputs and extra waits
    `CHECK_RW(7'h10, 16'h00AA, 2'b11, 1'b1) 
    `CHECK_VAL(16'h00AA) 

    $display("time: $d", $time);
    wait(clk == 1'b0);
    `DISPLAY_STATE
    `CHANGE_STATE(16'h0001)
    `DISPLAY_STATE
    `CHANGE_STATE(16'h0000)
    `DISPLAY_STATE

    $display("time: $d", $time);
    wait(clk == 1'b0);

    $display("time: $d", $time);
    wait(clk == 1'b0);
    wait(clk == 1'b0);
    wait(clk == 1'b0);
    $display("time: $d", $time);
//#10; 
//wait(clk == 1'b0);
// wait(clk == 1'b1);
// wait(clk == 1'b0);
// wait(clk == 1'b1);
// `SET_READ(7'h10,1'b1)
//#10;
//`READ_REG(7'h10,1'b1)
 
// YOUR STIMULUS GOES HERE!

   #5 $finish;
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


endmodule

