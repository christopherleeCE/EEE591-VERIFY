 //top4 ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   `CLEAR_ALL
   `CHIP_RESET
   bit_mask_array = {16'h0000, 16'h00FF, 16'hFF00, 16'hFFFF};

   /////////////////////////////////////////////////////////////////////////////////////
   //test
   /////////////////////////////////////////////////////////////////////////////////////

   //$display("my_access_array: %p", my_access_array);

   // $display("out_reg %h", gen_exp_ret);
   // $display("my_wr_val %h", my_wr_val);
   // `GEN_EXP_VAL(my_wr_val,my_reg_val,my_access_array[5],gen_exp_ret)
   // $display("out reg: %h", gen_exp_ret);


   $display("calling finish");


   ///////////////////////////////////////////////////////////////////////////////////// 
   //cs = 1
   ///////////////////////////////////////////////////////////////////////////////////// 
   $display("\n \n \n");
   `DISPLAY_STATE
    
   //rst non aliased testing
   $display("calling `CHIP_RESET...");
   `CHIP_RESET
   `DISPLAY_STATE
   for (int addr_idx = 0; addr_idx < 7; addr_idx ++) begin
      $display("\naddr_idx = %0d (%s)", addr_idx, reg_names[addr_idx]);
      $display("==================================================");
      for (int _be = 0; _be < 4; _be ++) begin
         for (int i = 0; i < 4; i++) begin
            if(addr_idx == 4) begin $display("dry soup"); end //HERE 16
            my_wr_val = stim_array[i]; //this step is needed, I don't know why
            `GEN_EXP_VAL(my_wr_val,bit_mask_array[_be],my_reg_val,my_access_array[addr_idx],address_array[addr_idx],gen_exp_ret)
            $display("\n_be : %2b", _be);
            $display("my_wr_val %h", my_wr_val);
            $display("gen_exp_ret: %h", gen_exp_ret);
            $display("address and reg name: %0h (%s)", address_array[addr_idx], reg_names[addr_idx]);
            //$display("%h", (gen_exp_ret & bit_mask_array[_be]));
            `CHECK_RW(address_array[addr_idx], stim_array[i], (gen_exp_ret), _be, 1'b1)
         end
      end
   end

   normal_reg_values [0:6] = {16'h0210, 16'h0001, 16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0000};

   $display("\n \n \n");
   `DISPLAY_STATE

   //normal non aliased testing
   $display("calling `CHIP_NORMAL...");
   `CHIP_NORMAL
   `DISPLAY_STATE
   for (int addr_idx = 0; addr_idx < 7; addr_idx ++) begin
      $display("\naddr_idx = %0d (%s)", addr_idx, reg_names[addr_idx]);
      $display("==================================================");
      for (int _be = 0; _be < 4; _be ++) begin
         for (int i = 0; i < 4; i++) begin
            if(addr_idx == 4) begin $display("dry soup"); end //HERE 16
            `CHIP_NORMAL
            `DISPLAY_STATE
            `WRITE_REG(address_array[addr_idx], (gen_exp_ret), _be, 1'b1)
            my_wr_val = stim_array[i]; //this step is needed, I don't know why
            `GEN_EXP_VAL(my_wr_val,bit_mask_array[_be],normal_reg_values[addr_idx],my_access_array[addr_idx],address_array[addr_idx],gen_exp_ret)
            $display("\n_be : %2b", _be);
            $display("my_wr_val %h", my_wr_val);
            $display("gen_exp_ret: %h", gen_exp_ret);
            $display("address and reg name: %0h (%s)", address_array[addr_idx], reg_names[addr_idx]);
            //$display("%h", (gen_exp_ret & bit_mask_array[_be]));
            $display("%h", stim_array[i]);
            `CHECK_RW(address_array[addr_idx], stim_array[i], (gen_exp_ret), _be, 1'b1)
         end
      end
   end

   ////////////////////////////////////////////////////////
   // READ all four values from ALU OUT IN Normal Mode
   // needs an extra step to load value in
   ///////////////////////////////////////////////////////////
   `CHIP_NORMAL
   `DISPLAY_STATE
   for (int _be = 3; _be < 4; _be ++) begin  //byte enable set to 3 for entire loop so full value gets written into ALU OUT

      $display("ALU OUT TESTING");
      `CHECK_RW(VCHIP_ALU_LEFT_ADDR, 16'h5555,  16'h5555, bit_mask_array[_be], 1'b1)
      `READ_REG(VCHIP_ALU_RIGHT_ADDR,1'b1)                           
      $display("alu right read: [data_out] = [%h]", data_out);
      `CHECK_RW(VCHIP_CMD_ADDR, 16'h8001,  16'h0001, 2'b11, 1'b1)
      byte_en=  bit_mask_array[_be];
      `READ_REG(VCHIP_ALU_OUT_ADDR,1'b1) 
      $display("read: [data_out] = [%h]", data_out);
      `READ_REG(VCHIP_ALU_OUT_ADDR,1'b0) 


      `CHECK_RW(VCHIP_ALU_LEFT_ADDR, 16'hAAAA,  16'hAAAA, bit_mask_array[_be], 1'b1)
      `CHECK_RW(VCHIP_CMD_ADDR, 16'h8001,  16'h0001, 2'b11, 1'b1)
      byte_en=  bit_mask_array[_be];
      `READ_REG(VCHIP_ALU_OUT_ADDR,1'b1) 
      $display("read: [data_out] = [%h]", data_out);
      `READ_REG(VCHIP_ALU_OUT_ADDR,1'b0) 


      `CHECK_RW(VCHIP_ALU_LEFT_ADDR, 16'hFFFF,  16'hFFFF,bit_mask_array[_be], 1'b1)
      `CHECK_RW(VCHIP_CMD_ADDR, 16'h8001,  16'h0001, 2'b11, 1'b1)
      byte_en=  bit_mask_array[_be];
      `READ_REG(VCHIP_ALU_OUT_ADDR,1'b1) 
      $display("read: [data_out] = [%h]", data_out);
      `READ_REG(VCHIP_ALU_OUT_ADDR,1'b0) 

      `CHECK_RW(VCHIP_ALU_LEFT_ADDR, 16'h0000,  16'h0000, bit_mask_array[_be], 1'b1)
      `CHECK_RW(VCHIP_CMD_ADDR, 16'h8001,  16'h0001, 2'b11, 1'b1)
      byte_en=  bit_mask_array[_be];
      `READ_REG(VCHIP_ALU_OUT_ADDR,1'b1) 
      $display("read: [data_out] = [%h]", data_out);
      `READ_REG(VCHIP_ALU_OUT_ADDR,1'b0) 

   end

 


   /////////////////////////////////////////////////////////////////////
   // ERROR/////////////////////////////////////////////////////////////
   /////////////////////////////////////////////////////////////////////
   error_reg_values [0:6] = {16'h0210, 16'h0002, 16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0000};


   $display("\n \n \n");
   `DISPLAY_STATE 

   //error state non aliased testing

   $display("calling `CHIP_ER...");
   scratch = 16'h0001;
   `CHIP_ERROR(scratch,1'b0)
   `DISPLAY_STATE
   for (int addr_idx = 0; addr_idx < 7; addr_idx ++) begin
      $display("\naddr_idx = %0d (%s)", addr_idx, reg_names[addr_idx]);
      $display("==================================================");
      for (int _be = 0; _be < 4; _be ++) begin
         for (int i = 0; i < 4; i++) begin
            if(addr_idx == 4) begin $display("dry soup"); end //HERE 16
            `CHIP_ERROR(scratch,1'b0) //set intiial reset vlaue to 1
            `DISPLAY_STATE
            my_wr_val = 16'h0001; //this step is needed, I don't know why
            `GEN_EXP_VAL(my_wr_val,bit_mask_array[2'b11],error_reg_values[addr_idx],my_access_array[addr_idx],address_array[addr_idx],gen_exp_ret)
            $display("\n_be : %2b", _be);
            $display("my_wr_val %h", my_wr_val);
            $display("gen_exp_ret: %h", gen_exp_ret);
            $display("address and reg name: %0h (%s)", address_array[addr_idx], reg_names[addr_idx]);
            //$display("%h", (gen_exp_ret & bit_mask_array[_be]));
            $display("%h", stim_array[i]);
            if (address_array[addr_idx] == VCHIP_CMD_ADDR) begin
               $display("if triggred");
               my_wr_val = 16'h800C; //acount for the cm reg value being 800c to enter error state
               `GEN_EXP_VAL(my_wr_val,bit_mask_array[2'b11],error_reg_values[addr_idx],my_access_array[addr_idx],address_array[addr_idx],gen_exp_ret)
               `CHECK_RW(address_array[addr_idx], stim_array[i], gen_exp_ret, _be, 1'b1)
            end

            else
            `CHECK_RW(address_array[addr_idx], stim_array[i], (gen_exp_ret), _be, 1'b1)
         end
      end
   end

   error_reg_values [0:6] = {16'h0210, 16'h0102, 16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0000};
   //////////////////////////////////////////////////////////////////////////////////
   //////////ERROR state with interrupts enabled then cleared => NORMAL /////////////
   /////////////////////////////////////////////////////////////////////////////////
   $display("calling `CHIP_ER int1 and int2 enabled..");
   `CHIP_ERROR(scratch,1'b1)
   `DISPLAY_STATE
   $display("==================================================");
   for (int addr_idx = 1; addr_idx ==1; addr_idx ++) begin
      $display("\naddr_idx = %0d (%s)", addr_idx, reg_names[addr_idx]);
      $display("==================================================");
      for (int _be = 0; _be < 4; _be ++) begin
         for (int i = 0; i < 4; i++) begin
            if(addr_idx == 4) begin $display("dry soup"); end //HERE
            `CHIP_ERROR(scratch,1'b1) //set intiial reset vlaue to 1
            `DISPLAY_STATE
            my_wr_val = stim_array[i]; //sets to an interrupt high and in error state
            `GEN_EXP_VAL(my_wr_val,bit_mask_array[_be],error_reg_values[addr_idx],my_access_array[addr_idx],address_array[addr_idx],gen_exp_ret)
            $display("old ger: %h", gen_exp_ret);

            //todo clean up
            for (int i = 0; i < 16; ++i) begin         
               //$write(" %0d", access_array[i]);      
               case (my_access_array[addr_idx][i])                  
                  RO:                                  
                  gen_exp_ret[i] = error_reg_values[addr_idx][i];  
                  W1C:                                 
                  gen_exp_ret[i] = error_reg_values[addr_idx][i] && (~my_wr_val[i] || ~bit_mask_array[_be][i]); 
                  RW:                                      
                  gen_exp_ret[i] =  my_wr_val[i] & bit_mask_array[_be][i];      
                  default:                                 
                  gen_exp_ret[i] = error_reg_values[addr_idx][i] & bit_mask_array[_be][i];      
                                                
               endcase                                     
            end

            $display("new ger: %h", gen_exp_ret);

            $display("\n_be : %2b", _be);
            $display("my_wr_val %h", my_wr_val);
            $display("gen_exp_ret: %h", gen_exp_ret);
            $display("address and reg name: %0h (%s)", address_array[addr_idx], reg_names[addr_idx]);
            //$display("%h", (gen_exp_ret & bit_mask_array[_be]));
            `CHECK_RW(address_array[addr_idx], stim_array[i], (gen_exp_ret), _be, 1'b1)
            $display("do: %h", data_out);
         end
      end
   end

   maroon = 1;
   gold = 0;
   wait(clk == 1);
   wait(clk == 0);
   wait(clk == 1);
   wait(clk == 0);
   `GEN_EXP_VAL(my_wr_val,bit_mask_array[2'b11],error_reg_values[3],my_access_array[3],address_array[3],gen_exp_ret)

   expvi_reg_values [0:6] = {16'h0000, 16'h0008, 16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0000};

   $display("\n \n \n");
   `DISPLAY_STATE   

   //expvi non aliased testing

   $display("calling `CHIP_EXP_VIO...");
   `CHIP_EXP_VIO
   `DISPLAY_STATE
   for (int addr_idx = 0; addr_idx < 7; addr_idx ++) begin
      $display("\naddr_idx = %0d (%s)", addr_idx, reg_names[addr_idx]);
      $display("==================================================");
      for (int _be = 0; _be < 4; _be ++) begin
         for (int i = 0; i < 4; i++) begin
            if(addr_idx == 4) begin $display("dry soup"); end //HERE
            `CHIP_EXP_VIO
            `DISPLAY_STATE
            my_wr_val = 16'h0000; //this step is needed, I don't know why
            if (address_array[addr_idx] != VCHIP_VER_ADDR) begin
               `GEN_EXP_VAL(my_wr_val,bit_mask_array[_be],expvi_reg_values[addr_idx],my_access_array[addr_idx],address_array[addr_idx],gen_exp_ret)
            end else begin
               gen_exp_ret = 16'h0000;
            end
            $display("\n_be : %2b", _be);
            $display("my_wr_val %h", my_wr_val);
            $display("gen_exp_ret: %h", gen_exp_ret);
            $display("address and reg name: %0h (%s)", address_array[addr_idx], reg_names[addr_idx]);
            //$display("%h", (gen_exp_ret & bit_mask_array[_be]));
            $display("%h", stim_array[i]);
            `CHECK_RW(address_array[addr_idx], stim_array[i], (gen_exp_ret), _be, 1'b1)
         end
      end
   end
   
   `CHIP_RESET

   // ///////////////////////////////////////////////////////////////////////////////////// 
   // //cs = 0 -- Verichip is unselected; read all zeros
   // /////////////////////////////////////////////////////////////////////////////////////
   $display("\n \n \n");
   $display("cs %h", chip_select);   
   $display("\n \n \n");
   $display("cs %h", chip_select);   

   //rst non aliased testing, with cs = 0

   $display("\n \n \n");
   `DISPLAY_STATE
   $display("\n \n \n");
   `DISPLAY_STATE

   for (int addr_idx = 0; addr_idx < 7; addr_idx ++) begin
      $display("calling `CHIP_RESET cs = 0");
      `CHIP_RESET
      `DISPLAY_STATE

      $display("%0h (%s)", address_array[addr_idx], reg_names[addr_idx]);
      // Set ALU_LEFT to non-zero value.
      `WRITE_REG(address_array[addr_idx], 16'hBEAF, 2'b11, 1'b1)
      `READ_REG(address_array[addr_idx], 1'b1)
      
      //////////////////////////////////////////////////   
      // Check read write and byte enable combinations.
      //////////////////////////////////////////////////
      for (int _be = 0; _be < 4; _be ++) begin
         for (int i = 0; i < 4; i++) begin
               if(addr_idx == 4) begin $display("dry soup"); end //HERE
               $display("\n_be : %2b", _be);
               $display("my_wr_val %h", my_wr_val);
               $display("gen_exp_ret: %h", gen_exp_ret);
               $display("address and reg name: %0h (%s)", address_array[addr_idx], reg_names[addr_idx]);
               //$display("%h", (gen_exp_ret & bit_mask_array[_be]));
            `CHECK_RW(address_array[addr_idx], stim_array[i], 16'h0, _be, 1'b0)
         end
      end

      $display("\n \n \n");
      `DISPLAY_STATE

      //nrm state non aliased testing, with cs = 0

      $display("calling `CHIP_NORMAL...");
      `CHIP_NORMAL
      `DISPLAY_STATE

      `WRITE_REG(address_array[addr_idx], 16'h0001, 2'b11, 1'b1) //changed this from BEAF
      `READ_REG(address_array[addr_idx], 1'b1)

      // Check r/w all be and write combinations.
      for (int _be = 0; _be < 4; _be ++) begin
         for (int i = 0; i < 4; i++) begin
            if(addr_idx == 4) begin $display("dry soup"); end //HERE
            $display("\n_be : %2b", _be);
            $display("my_wr_val %h", my_wr_val);
            $display("gen_exp_ret: %h", gen_exp_ret);
            $display("address and reg name: %0h (%s)", address_array[addr_idx], reg_names[addr_idx]);
            //$display("%h", (gen_exp_ret & bit_mask_array[_be]));
            `CHECK_RW(address_array[addr_idx], stim_array[i], 16'h0, _be, 1'b0)
         end
      end

      $display("\n \n \n");
      `DISPLAY_STATE 
      $display("time: %d", $time);

      //err state non aliased testing cs = 0

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
      `WRITE_REG(address_array[addr_idx], 16'hBEAF, 2'b11, 1'b1)
      `READ_REG(address_array[addr_idx], 1'b1)

                                                         
      //write bad command to command reg to go into error   
      `WRITE_REG(VCHIP_CMD_ADDR, 16'h800C, 2'b11, 1'b1)     
      wait(clk == 1'b1); wait(clk == 1'b0); //min wait to see state change debug output   

      `DISPLAY_STATE

      // Check all byte enable and write combinations.
      for (int _be = 0; _be < 4; _be ++)
         for (int i = 0; i < 4; i++) begin
            if(addr_idx == 4) begin $display("dry soup"); end //HERE
            $display("\n_be : %2b", _be);
            $display("my_wr_val %h", my_wr_val);
            $display("gen_exp_ret: %h", gen_exp_ret);
            $display("address and reg name: %0h (%s)", address_array[addr_idx], reg_names[addr_idx]);
            //$display("%h", (gen_exp_ret & bit_mask_array[_be]));
            `CHECK_RW(address_array[addr_idx], stim_array[i], 16'h0, _be, 1'b0)
         end
         
      $display("\n \n \n");
      `DISPLAY_STATE   

      //all zeros, we are in cs = 0, garuentees genexpret = 0
      expvi_reg_values [0:6] = {16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0000};

      for (int _be = 0; _be < 4; _be ++) begin
         for (int i = 0; i < 4; i++) begin
            if(addr_idx == 4) begin $display("dry soup"); end //HERE
            `CHIP_EXP_VIO
            `DISPLAY_STATE
            my_wr_val = 16'h0000; //this step is needed, I don't know why
            if (address_array[addr_idx] != VCHIP_VER_ADDR) begin
               `GEN_EXP_VAL(my_wr_val,bit_mask_array[_be],expvi_reg_values[addr_idx],my_access_array[addr_idx],address_array[addr_idx],gen_exp_ret)
            end else begin
               gen_exp_ret = 16'h0000;
            end
            $display("\n_be : %2b", _be);
            $display("my_wr_val %h", my_wr_val);
            $display("gen_exp_ret: %h", gen_exp_ret);
            $display("address and reg name: %0h (%s)", address_array[addr_idx], reg_names[addr_idx]);
            //$display("%h", (gen_exp_ret & bit_mask_array[_be]));
            $display("%h", stim_array[i]);
            $display("chiptune");
            `CHECK_RW(address_array[addr_idx], stim_array[i], (gen_exp_ret), _be, 1'b0)
         end
      end
   end


   ///////////////////////////////////////
   // ALIAS TESTING- for all states
   ///////////////////////////////////////

   $display("forloop1");

   // Testing Reset State for all byte_enables and chip select 0 & 1
   for (int _be = 0; _be < 4; _be ++) begin
      `CHIP_RESET
      `DISPLAY_STATE
      `ALIASING_WRITE_CHECK(VCHIP_ALU_LEFT_ADDR,_be,1'b1, 16'h0000) // cs high
      `ALIASING_WRITE_CHECK(VCHIP_ALU_LEFT_ADDR,_be,1'b0, 16'h0000) // cs low
      `ALIASING_READ_CHECK(VCHIP_ALU_LEFT_ADDR, 16'h0000,16'hFFFF) // read validate

      `CHIP_RESET
      `DISPLAY_STATE
      `ALIASING_WRITE_CHECK(VCHIP_ALU_RIGHT_ADDR,_be,1'b1, 16'h0000) // cs high
      `ALIASING_WRITE_CHECK(VCHIP_ALU_RIGHT_ADDR,_be,1'b0, 16'h0000) // cs low
      `ALIASING_READ_CHECK(VCHIP_ALU_RIGHT_ADDR, 16'h0000,16'hFFFF) // read validate


      `CHIP_RESET
      `DISPLAY_STATE
      `ALIASING_WRITE_CHECK(VCHIP_ALU_OUT_ADDR,_be,1'b1, 16'h0000) // cs high
      `ALIASING_WRITE_CHECK(VCHIP_ALU_OUT_ADDR,_be,1'b0, 16'h0000) // cs low
      `ALIASING_READ_CHECK(VCHIP_ALU_OUT_ADDR, 16'h0000,16'hFFFF) // read validate

      $display("ALIAS RESET 1");
      `ALIASING_WRITE_CHECK(VCHIP_CON_ADDR,_be,1'b1, 16'h0000) // cs high
      `ALIASING_WRITE_CHECK(VCHIP_CON_ADDR,_be,1'b0, 16'h0000) // cs low
      `ALIASING_READ_CHECK(VCHIP_CON_ADDR, 16'h0000,16'hFFFF) // read validate

      $display("ALIAS RESET 2");
      `ALIASING_WRITE_CHECK(VCHIP_CMD_ADDR,_be,1'b1, 16'h0000) // cs high
      `ALIASING_WRITE_CHECK(VCHIP_CMD_ADDR,_be,1'b0, 16'h0000) // cs low
      `ALIASING_READ_CHECK(VCHIP_CMD_ADDR, 16'h0000,16'hFFFF) // read validate

      $display("ALIAS RESET 3");
      `ALIASING_WRITE_CHECK(VCHIP_STA_ADDR,_be,1'b1, 16'h0308) // cs high
      `ALIASING_WRITE_CHECK(VCHIP_STA_ADDR,_be,1'b0, 16'h0308) // cs low
      `ALIASING_READ_CHECK(VCHIP_STA_ADDR, 16'h0308,16'hFFFF) // read validate

      $display("ALIAS RESET 4");
      `ALIASING_WRITE_CHECK(VCHIP_VER_ADDR,_be,1'b1, 16'h0000) // cs high
      `ALIASING_WRITE_CHECK(VCHIP_VER_ADDR,_be,1'b0, 16'h0000) // cs low
      `ALIASING_READ_CHECK(VCHIP_VER_ADDR, 16'h0000,16'hFFFF) // read validate
   end

   $display("forloop2");
   ///////////////////////////////////////////////////////////////////
   // Testing Normal State for all byte_enables and chip select 0 & 1
   ///////////////////////////////////////////////////////////////////
   for (int _be = 0; _be < 4; _be ++) begin
      `CHIP_NORMAL
      `DISPLAY_STATE
      `ALIASING_WRITE_CHECK(VCHIP_ALU_LEFT_ADDR,_be,1'b1, 16'h0000) // cs high
      `ALIASING_WRITE_CHECK(VCHIP_ALU_LEFT_ADDR,_be,1'b0, 16'h0000) // cs low
      `ALIASING_READ_CHECK(VCHIP_ALU_LEFT_ADDR, 16'h0000,16'hFFFF) // read validate

      `CHIP_NORMAL
      `DISPLAY_STATE
      `ALIASING_WRITE_CHECK(VCHIP_ALU_RIGHT_ADDR,_be,1'b1, 16'h0000) // cs high
      `ALIASING_WRITE_CHECK(VCHIP_ALU_RIGHT_ADDR,_be,1'b0, 16'h0000) // cs low
      `ALIASING_READ_CHECK(VCHIP_ALU_RIGHT_ADDR, 16'h0000,16'hFFFF) // read validate

      `CHIP_NORMAL
      `DISPLAY_STATE
      `ALIASING_WRITE_CHECK(VCHIP_ALU_OUT_ADDR,_be,1'b1, 16'h0000) // cs high
      `ALIASING_WRITE_CHECK(VCHIP_ALU_OUT_ADDR,_be,1'b0, 16'h0000) // cs low
      `ALIASING_READ_CHECK(VCHIP_ALU_OUT_ADDR, 16'h0000,16'hFFFF) // read validate

      `ALIASING_WRITE_CHECK(VCHIP_CON_ADDR,_be,1'b1, 16'h0000) // cs high
      `ALIASING_WRITE_CHECK(VCHIP_CON_ADDR,_be,1'b0, 16'h0000) // cs low
      `ALIASING_READ_CHECK(VCHIP_CON_ADDR, 16'h0000,16'hFFFF) // read validate

      `ALIASING_WRITE_CHECK(VCHIP_CMD_ADDR,_be,1'b1, 16'h0000) // cs high
      `ALIASING_WRITE_CHECK(VCHIP_CMD_ADDR,_be,1'b0, 16'h0000) // cs low
      `ALIASING_READ_CHECK(VCHIP_CMD_ADDR, 16'h0000,16'hFFFF) // read validate

      `ALIASING_WRITE_CHECK(VCHIP_STA_ADDR,_be,1'b1, 16'h0308) // cs high
      `ALIASING_WRITE_CHECK(VCHIP_STA_ADDR,_be,1'b0, 16'h0308) // cs low
      `ALIASING_READ_CHECK(VCHIP_STA_ADDR, 16'h0000,16'hFFFF) // read validate

      `ALIASING_WRITE_CHECK(VCHIP_VER_ADDR,_be,1'b1, 16'h0000) // cs high
      `ALIASING_WRITE_CHECK(VCHIP_VER_ADDR,_be,1'b0, 16'h0000) // cs low
      `ALIASING_READ_CHECK(VCHIP_VER_ADDR, 16'h0000,16'hFFFF) // read validate
   end

   $display("forloop3");
   /////////////////////////////////////////////////////////////////
   // Testing Error State for all byte_enables and chip select 0 & 1
   /////////////////////////////////////////////////////////////////
   for (int _be = 0; _be < 4; _be ++) begin
      scratch = 16'h0000;
      `CHIP_ERROR(scratch,1'b0)
      `DISPLAY_STATE
      `ALIASING_WRITE_CHECK(VCHIP_ALU_LEFT_ADDR,_be,1'b1, 16'h0000) // cs high
      `ALIASING_WRITE_CHECK(VCHIP_ALU_LEFT_ADDR,_be,1'b0, 16'h0000) // cs low
      `ALIASING_READ_CHECK(VCHIP_ALU_LEFT_ADDR, 16'h0000,16'hFFFF) // read validate

      `ALIASING_WRITE_CHECK(VCHIP_ALU_RIGHT_ADDR,_be,1'b1, 16'h0000) // cs high
      `ALIASING_WRITE_CHECK(VCHIP_ALU_RIGHT_ADDR,_be,1'b0, 16'h0000) // cs low
      `ALIASING_READ_CHECK(VCHIP_ALU_RIGHT_ADDR, 16'h0000,16'hFFFF) // read validate

      `ALIASING_WRITE_CHECK(VCHIP_ALU_OUT_ADDR,_be,1'b1, 16'h0000) // cs high
      `ALIASING_WRITE_CHECK(VCHIP_ALU_OUT_ADDR,_be,1'b0, 16'h0000) // cs low
      `ALIASING_READ_CHECK(VCHIP_ALU_OUT_ADDR, 16'h0000,16'hFFFF) // read validate

      `ALIASING_WRITE_CHECK(VCHIP_CON_ADDR,_be,1'b1, 16'h0000) // cs high
      `ALIASING_WRITE_CHECK(VCHIP_CON_ADDR,_be,1'b0, 16'h0000) // cs low
      `ALIASING_READ_CHECK(VCHIP_CON_ADDR, 16'h0000,16'hFFFF) // read validate

      `ALIASING_WRITE_CHECK(VCHIP_CMD_ADDR,_be,1'b1, 16'h0000) // cs high
      `ALIASING_WRITE_CHECK(VCHIP_CMD_ADDR,_be,1'b0, 16'h0000) // cs low
      `ALIASING_READ_CHECK(VCHIP_CMD_ADDR, 16'h0000,16'hFFFF) // read validate

      `ALIASING_WRITE_CHECK(VCHIP_STA_ADDR,_be,1'b1, 16'h0008) // cs high
      `ALIASING_WRITE_CHECK(VCHIP_STA_ADDR,_be,1'b0, 16'h0008) // cs low
      `ALIASING_READ_CHECK(VCHIP_STA_ADDR, 16'h0000,16'hFFFF) // read validate

      `ALIASING_WRITE_CHECK(VCHIP_VER_ADDR,_be,1'b1, 16'h0000) // cs high
      `ALIASING_WRITE_CHECK(VCHIP_VER_ADDR,_be,1'b0, 16'h0000) // cs low
      `ALIASING_READ_CHECK(VCHIP_VER_ADDR, 16'h0000,16'hFFFF) // read validate
   end

   $display("forloop4");
   /////////////////////////////////////////////////////////////////////////////
   // Testing Export Violation State for all byte_enables and chip select 0 & 1
   //////////////////////////////////////////////////////////////////////////////
   for (int _be = 0; _be < 4; _be ++) begin
      `CHIP_EXP_VIO
      `DISPLAY_STATE
      `ALIASING_WRITE_CHECK(VCHIP_ALU_LEFT_ADDR,_be,1'b1, 16'h0000) // cs high
      `ALIASING_WRITE_CHECK(VCHIP_ALU_LEFT_ADDR,_be,1'b0, 16'h0000) // cs low
      `ALIASING_READ_CHECK(VCHIP_ALU_LEFT_ADDR, 16'h0000,16'hFFFF) // read validate

      `ALIASING_WRITE_CHECK(VCHIP_ALU_RIGHT_ADDR,_be,1'b1, 16'h0000) // cs high
      `ALIASING_WRITE_CHECK(VCHIP_ALU_RIGHT_ADDR,_be,1'b0, 16'h0000) // cs low
      `ALIASING_READ_CHECK(VCHIP_ALU_RIGHT_ADDR, 16'h0000,16'hFFFF) // read validate

      `ALIASING_WRITE_CHECK(VCHIP_ALU_OUT_ADDR,_be,1'b1, 16'h0000) // cs high
      `ALIASING_WRITE_CHECK(VCHIP_ALU_OUT_ADDR,_be,1'b0, 16'h0000) // cs low
      `ALIASING_READ_CHECK(VCHIP_ALU_OUT_ADDR, 16'h0000,16'hFFFF) // read validate

      `ALIASING_WRITE_CHECK(VCHIP_CON_ADDR,_be,1'b1, 16'h0000) // cs high
      `ALIASING_WRITE_CHECK(VCHIP_CON_ADDR,_be,1'b0, 16'h0000) // cs low
      `ALIASING_READ_CHECK(VCHIP_CON_ADDR, 16'h0000,16'hFFFF) // read validate

      `ALIASING_WRITE_CHECK(VCHIP_CMD_ADDR,_be,1'b1, 16'h0000) // cs high
      `ALIASING_WRITE_CHECK(VCHIP_CMD_ADDR,_be,1'b0, 16'h0000) // cs low
      `ALIASING_READ_CHECK(VCHIP_CMD_ADDR, 16'h0000,16'hFFFF) // read validate

      `ALIASING_WRITE_CHECK(VCHIP_STA_ADDR,_be,1'b1, 16'h0008) // cs high
      `ALIASING_WRITE_CHECK(VCHIP_STA_ADDR,_be,1'b0, 16'h0008) // cs low
      `ALIASING_READ_CHECK(VCHIP_STA_ADDR, 16'h0000,16'hFFFF) // read validate

      `ALIASING_WRITE_CHECK(VCHIP_VER_ADDR,_be,1'b1, 16'h0000) // cs high
      `ALIASING_WRITE_CHECK(VCHIP_VER_ADDR,_be,1'b0, 16'h0000) // cs low
      `ALIASING_READ_CHECK(VCHIP_VER_ADDR, 16'h0000,16'hFFFF) // read validate
   end

   $display("calling `CHIP_NORMAL...");
   `CHIP_NORMAL
   `DISPLAY_STATE

   // Set ALU_LEFT to non-zero value.
   `WRITE_REG(VCHIP_ALU_LEFT_ADDR, 16'hBEAF, 2'b11, 1'b1)
   `READ_REG(VCHIP_ALU_LEFT_ADDR, 1'b1)
   `CHECK_ALU_LEFT(16'hBEAF)

   // Check r/w all be and write combinations.
   for (int _be = 0; _be < 4; _be ++) begin
      for (int i = 0; i < 4; i++) begin
         `CHECK_RW(VCHIP_ALU_LEFT_ADDR, stim_array[i], 16'h0, _be, 1'b0)
         `CHECK_ALU_LEFT(16'hBEAF)
      end
   end


   // Check r/w all be and write combinations
   $display("calling `CHIP_NORMAL...");
   `CHIP_NORMAL
   `DISPLAY_STATE
   for (int _be = 0; _be < 4; _be ++) begin
      for (int i = 0; i < 4; i++) begin
         `CHECK_RW(VCHIP_ALU_LEFT_ADDR, stim_array[i], (stim_array[i] & bit_mask_array[_be]), _be, 1'b1)
      end
   end


   $display("status int routines");
   $display("===============================================");
   export_disable = 0;

   //status int sections

   //get into rst state with int1 = 0
   `DISPLAY_STATE
   `CHIP_RESET
   `DISPLAY_STATE
   `READ_REG(VCHIP_STA_ADDR, 1'b1)
   $display("rst, data_out: %h", data_out);
   `CHECK_VAL(16'h0000) //check that int1 = 0 in rst state

   $display("===============================================");

   //get into nrm state
   `DISPLAY_STATE
   `CHIP_NORMAL

   //check int1 = 0 initally
   $display("nrm, data_out: %h", data_out);
   `CHECK_VAL(16'h0001)
   `DISPLAY_STATE

   //get int1 = 1 in nrm state
   `CHIP_ERROR(16'h0000, 1'b1)  //get in1 high, values dont matter
   maroon = 1;
   gold = 0;
   wait(clk == 1);
   wait(clk == 0);
   wait(clk == 1);
   wait(clk == 0);
   `DISPLAY_STATE

   //check int1 = 1
   `READ_REG(VCHIP_STA_ADDR, 1'b1)
   $display("nrm, data_out: %h", data_out);
   `CHECK_VAL(16'h0101) //check that int1 = 0 in rst state

   //clear int1
   `WRITE_REG(VCHIP_STA_ADDR, 16'h0100, 2'b11, 1'b1)

   //check int1 = 0
   `READ_REG(VCHIP_STA_ADDR, 1'b1)
   $display("nrm, data_out: %h", data_out);
   `CHECK_VAL(16'h0001) //check that int1 = 0 in rst state

   $display("===============================================");

   //get into error state, int1 = 1
   `DISPLAY_STATE
   `CHIP_ERROR(16'h0000, 1'b1)

   //check int1 = 1
   `READ_REG(VCHIP_STA_ADDR, 1'b1)
   $display("err, data_out: %h", data_out);
   `CHECK_VAL(16'h0102) //check that int1 = 0 in rst state

   //clear int1
   `WRITE_REG(VCHIP_STA_ADDR, 16'h0100, 2'b11, 1'b1)

   //check int1 = 0
   `READ_REG(VCHIP_STA_ADDR, 1'b1)
   $display("err, data_out: %h", data_out);
   `CHECK_VAL(16'h0002) //check that int1 = 0 in rst state

   $display("===============================================");

   `DISPLAY_STATE
   ///////////////////////////////
   //get int1 = 1 in normal state
   ///////////////////////////////
   `CHIP_ERROR(16'h0000, 1'b1)  //get in1 high, values dont matter
   maroon = 1;
   gold = 0;
   wait(clk == 1);
   wait(clk == 0);
   wait(clk == 1);
   wait(clk == 0);
   `DISPLAY_STATE

   `READ_REG(VCHIP_STA_ADDR, 1'b1)
   $display("err, data_out: %h", data_out);
   `CHECK_VAL(16'h0101) //check that int1 = 0 in nrm state

   //assert exp disable, wait 2clk to ensure its in reg
   export_disable <= 1'b1; 
   wait(clk == 1'b1); wait(clk == 1'b0);
   wait(clk == 1'b1); wait(clk == 1'b0);
                        
   //get into expvio
   `WRITE_REG(VCHIP_CMD_ADDR, 16'h8008, 2'b11, 1'b1)                                  
   wait(clk == 1'b1); wait(clk == 1'b0);

   `READ_REG(VCHIP_STA_ADDR, 1'b1)
   $display("expvi, data_out: %h", data_out);
   `CHECK_VAL(16'h0308)

   //clear int2
   `WRITE_REG(VCHIP_STA_ADDR, 16'h0200, 2'b11, 1'b1)

   `READ_REG(VCHIP_STA_ADDR, 1'b1)
   $display("expvi, data_out: %h", data_out);
   `CHECK_VAL(16'h0108)

   //clear int1
   `WRITE_REG(VCHIP_STA_ADDR, 16'h0100, 2'b11, 1'b1)

   `READ_REG(VCHIP_STA_ADDR, 1'b1)
   $display("expvi, data_out: %h", data_out);
   `CHECK_VAL(16'h0008)

   $display("===============================================");
