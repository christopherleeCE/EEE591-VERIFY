 //top5 ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

   export_disable = 0;

   wait(clk == 0); wait(clk == 1);
   wait(clk == 0); wait(clk == 1);
   // wait(clk == 0);
   // $display("`GBC called%t", $time);
   // `GEN_BAD_CMD //called on neg edge, appears on next pos edge
   // $display("`GEV called%t", $time);
   // `GEN_EXP_VIO
   //on negedge, not on the next posedge, but the one after
   //on posedge, not on the next posedge, but the one after

   //////////////////////////////////////
   //RESET
   //////////////////////////////////////
   `CLEAR_ALL
   `CHIP_RESET
   `STATE_MASTER(0,0,0,0,0) // M = 0, G = 0
   `CHIP_RESET
   `STATE_MASTER(1,0,1,0,0) // M = 0, G = 1
   `CHIP_RESET
   `STATE_MASTER(0,1,0,0,0) // M = 1, G = 0
   `CHIP_RESET
   `STATE_MASTER(0,1,1,0,0) // M = 1, G = 1
   `CHIP_RESET
   `STATE_MASTER(0,0,0,0,1) // M = 0, G = 0, trigger bad_cmd 
   `CHIP_RESET
   `STATE_MASTER(0,0,0,1,0) // M = 0, G = 0, trigger export exp_vio
   `CHIP_RESET
   `STATE_MASTER(0,0,0,0,0) // assert rst


   //NORMAL
   `CLEAR_ALL
   `CHIP_NORMAL
   `STATE_MASTER(1,0,0,0,0) // M = 0, G = 0
   `CHIP_NORMAL
   `STATE_MASTER(1,0,1,0,0) // M = 0, G = 1
   `CHIP_NORMAL
   `STATE_MASTER(1,1,0,0,0) // M = 1, G = 0
   `CHIP_NORMAL
   `STATE_MASTER(1,1,1,0,0) // M = 1, G = 1
   `CHIP_NORMAL
   `STATE_MASTER(2,0,0,0,1) // M = 0, G = 0, trigger bad_cmd 
   `CHIP_NORMAL
   `STATE_MASTER(8,0,0,1,0) // M = 0, G = 0, trigger export exp_vio
   `CHIP_RESET
   `STATE_MASTER(0,0,0,0,0) // assert rst

   //ERROR
   `CLEAR_ALL
   `CHIP_ERROR(0, 1)
   `STATE_MASTER(2,0,0,0,0) // M = 0, G = 0
   `CHIP_ERROR(0, 1)
   `STATE_MASTER(2,0,1,0,0) // M = 0, G = 1
   `CHIP_ERROR(0, 1)
   `STATE_MASTER(1,1,0,0,0) // M = 1, G = 0
   `CHIP_ERROR(0, 1)
   `STATE_MASTER(2,1,1,0,0) // M = 1, G = 1
   `CHIP_ERROR(0, 1)

   //////////////////////////////////
   // M = 0, G = 0, trigger bad_cmd 
   //////////////////////////////////
   export_disable = 1'b0;
   wait(clk == 1'b0); wait(clk == 1'b1); wait(clk == 1'b0);

   export_disable = 1'b1;
   wait(clk == 1'b0); wait(clk == 1'b1); wait(clk == 1'b0);

   export_disable = 1'b0;
   wait(clk == 1'b0); wait(clk == 1'b1); wait(clk == 1'b0);
   //try get into expvio                                  
   `WRITE_REG(VCHIP_CMD_ADDR, 16'h800A, 2'b11, 1'b1)  
   wait(clk == 0); wait(clk == 1); wait(clk == 0);    
                                                
   `READ_REG(VCHIP_STA_ADDR, 1'b1)                    
   $display("expvi, data_out: %h", data_out);
   wait(clk == 0); wait(clk == 1); wait(clk == 0); 
   maroon = 0; gold = 0;                            
   `CHECK_STATE(2)

   `STATE_MASTER(2,0,0,0,1)
   `CHIP_ERROR(0, 1)

   `CHIP_ERROR(0, 1)
   export_disable = 1'b0;
   wait(clk == 1'b0); wait(clk == 1'b1); wait(clk == 1'b0);

   //try get into expvio                                  
   `WRITE_REG(VCHIP_CMD_ADDR, 16'h800A, 2'b11, 1'b1)  
   wait(clk == 0); wait(clk == 1); wait(clk == 0);    
                                                
   `READ_REG(VCHIP_STA_ADDR, 1'b1)                    
   $display("expvi, data_out: %h", data_out);
   wait(clk == 0); wait(clk == 1); wait(clk == 0); 
   maroon = 0; gold = 0;                            
   `CHECK_STATE(2)

      `CHIP_ERROR(0, 1)
      export_disable = 1'b1;
      wait(clk == 1'b0); wait(clk == 1'b1); wait(clk == 1'b0);

      //try get into expvio                                  
      `WRITE_REG(VCHIP_CMD_ADDR, 16'h800A, 2'b11, 1'b1)  
      wait(clk == 0); wait(clk == 1); wait(clk == 0);    
                                                         
      `READ_REG(VCHIP_STA_ADDR, 1'b1)                    
      $display("expvi, data_out: %h", data_out);
      wait(clk == 0); wait(clk == 1); wait(clk == 0); 
      maroon = 0; gold = 0;                            
      `CHECK_STATE(2)

   `STATE_MASTER(2,0,0,1,0)
   `CHIP_RESET
   `STATE_MASTER(0,0,0,0,0)

   ////////////////////////////////////////   
   // M = 0, G = 0, trigger export exp_vio
   ////////////////////////////////////////
   `CLEAR_ALL
   `CHIP_EXP_VIO
   `STATE_MASTER(8,0,0,0,0)
   `CHIP_EXP_VIO
   `STATE_MASTER(8,0,1,0,0)
   `CHIP_EXP_VIO
   `STATE_MASTER(8,1,0,0,0)
   `CHIP_EXP_VIO
   `STATE_MASTER(8,1,1,0,0)
   `CHIP_EXP_VIO

   export_disable = 1'b0;
   wait(clk == 1'b0); wait(clk == 1'b1); wait(clk == 1'b0);

   //try get into expvio                                  
   `WRITE_REG(VCHIP_CMD_ADDR, 16'h800A, 2'b11, 1'b1)  
   wait(clk == 0); wait(clk == 1); wait(clk == 0);    
                                                      
   `READ_REG(VCHIP_STA_ADDR, 1'b1)                    
   $display("expvi, data_out: %h", data_out);
   wait(clk == 0); wait(clk == 1); wait(clk == 0); 
   maroon = 0; gold = 0;                            
   `CHECK_STATE(8)

      `CHIP_EXP_VIO
      export_disable = 1'b1;
      wait(clk == 1'b0); wait(clk == 1'b1); wait(clk == 1'b0);

      //try get into expvio                                  
      `WRITE_REG(VCHIP_CMD_ADDR, 16'h800A, 2'b11, 1'b1)  
      wait(clk == 0); wait(clk == 1); wait(clk == 0);    
                                                         
      `READ_REG(VCHIP_STA_ADDR, 1'b1)                    
      $display("expvi, data_out: %h", data_out);
      wait(clk == 0); wait(clk == 1); wait(clk == 0); 
      maroon = 0; gold = 0;                            
      `CHECK_STATE(8)

   export_disable = 1'b0;
   wait(clk == 0); wait(clk == 1); wait(clk == 0); 
   `STATE_MASTER(8,0,0,0,1)

   `CHIP_EXP_VIO
   export_disable = 1'b0;
   wait(clk == 1'b0); wait(clk == 1'b1); wait(clk == 1'b0);

   //try get into expvio                                  
   `WRITE_REG(VCHIP_CMD_ADDR, 16'h800A, 2'b11, 1'b1)  
   wait(clk == 0); wait(clk == 1); wait(clk == 0);    
                                                   
   `READ_REG(VCHIP_STA_ADDR, 1'b1)                    
   $display("expvi, data_out: %h", data_out);
   wait(clk == 0); wait(clk == 1); wait(clk == 0); 
   maroon = 0; gold = 0;                            
   `CHECK_STATE(8)

      `CHIP_EXP_VIO
      export_disable = 1'b1;
      wait(clk == 1'b0); wait(clk == 1'b1); wait(clk == 1'b0);

      //try get into expvio                                  
      `WRITE_REG(VCHIP_CMD_ADDR, 16'h800A, 2'b11, 1'b1)  
      wait(clk == 0); wait(clk == 1); wait(clk == 0);    
                                                         
      `READ_REG(VCHIP_STA_ADDR, 1'b1)                    
      $display("expvi, data_out: %h", data_out);
      wait(clk == 0); wait(clk == 1); wait(clk == 0); 
      maroon = 0; gold = 0;                            
      `CHECK_STATE(8)

   `STATE_MASTER(8,0,0,1,0)
   `CHIP_RESET //check if reset gets you out of exp_vio
   `STATE_MASTER(0,0,0,0,0)