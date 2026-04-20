`CHECK_RW(VCHIP_VER_ADDR, 16'h3000, 16'h0210, 2'b11, 1'b1)
`CHECK_RW(VCHIP_STA_ADDR, 16'h3000, 16'h0000, 2'b11, 1'b1)
`CHECK_RW(VCHIP_CMD_ADDR, 16'h3000, 16'h0000, 2'b11, 1'b1)
`CHECK_RW(VCHIP_CON_ADDR, 16'h3000, 16'h0000, 2'b11, 1'b1)
`CHECK_RW(VCHIP_ALU_LEFT_ADDR, 16'h3000, 16'h3000, 2'b11, 1'b1)
`CHECK_RW(VCHIP_ALU_RIGHT_ADDR, 16'h3000, 16'h3000, 2'b11, 1'b1)
`CHECK_RW(VCHIP_ALU_OUT_ADDR, 16'h3000, 16'h0000, 2'b11, 1'b1)

`CHECK_RW(VCHIP_VER_ADDR, 16'hd000, 16'h0210, 2'b11, 1'b1)
`CHECK_RW(VCHIP_STA_ADDR, 16'hd000, 16'h0000, 2'b11, 1'b1)
`CHECK_RW(VCHIP_CMD_ADDR, 16'hd000, 16'h0000, 2'b11, 1'b1)
`CHECK_RW(VCHIP_CON_ADDR, 16'hd000, 16'h0000, 2'b11, 1'b1)
`CHECK_RW(VCHIP_ALU_LEFT_ADDR, 16'hd000, 16'hd000, 2'b11, 1'b1)
`CHECK_RW(VCHIP_ALU_RIGHT_ADDR, 16'hd000, 16'hd000, 2'b11, 1'b1)
`CHECK_RW(VCHIP_ALU_OUT_ADDR, 16'hd000, 16'h0000, 2'b11, 1'b1)


//add, cp valid, state error
`CLEAR_ALL
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

//error with overflow
`CHECK_RW(VCHIP_ALU_LEFT_ADDR, 16'h7FFF, 16'h7FFF, 2'b11, 1'b1)
`CHECK_RW(VCHIP_ALU_RIGHT_ADDR, 16'h7FFF, 16'h7FFF, 2'b11, 1'b1)
`DISPLAY_STATE
`CHECK_RW(VCHIP_CMD_ADDR, 16'h8001, 16'h0001, 2'b11, 1'b1)
`READ_REG(VCHIP_ALU_OUT_ADDR, 1'b1)
`DISPLAY_STATE
$display("cmd: %d", verichip.cmd);
$display("valid: %d", verichip.valid);
$display("data_out: %d", data_out);

