   //top6/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

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
   // `LI_AOUT(16'h0000)
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
   // `LI_AOUT(16'h0000)
   `DRIVE_CMD(16'h0001,16'hFFFF,16'h8005,16'h0001,16'hFFFF,16'h0000,4'h0)
   // `LI_AOUT(16'h0000)
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
   // `LI_AOUT(16'h0000)
   `DRIVE_CMD(16'h5555,16'h0001,16'h8007,16'h5555,16'h0001,16'h0000,4'h0)
   // `LI_AOUT(16'h0000)
   `DRIVE_CMD(16'hFFFF,16'hAAAA,16'h8007,16'hFFFF,16'hAAAA,16'h0000,4'h0)
   // `LI_AOUT(16'h0000)
   `DRIVE_CMD(16'h0001,16'hFFFF,16'h8007,16'h0001,16'hFFFF,16'h0000,4'h0)
   // `LI_AOUT(16'h0000)
   `DRIVE_CMD(16'hAAAA,16'h0001,16'h8007,16'hAAAA,16'h0001,16'h0000,4'h0)
   `DISPLAY_STATE


   // TODO have bad command with export_disable = 1 as well
   //////////////////////////////////////////////////////////
   // bad command
   ///////////////////////////////////////////////////////////
   $display("BAD CMD");
   for (logic [15:0] i =8; i <16; i++ ) begin
      `CHIP_RESET
      // `LI_AOUT(16'h0000)
      `DRIVE_CMD(16'h0001,16'h5555,(16'h8000 + i),16'h0001,16'h5555,16'h0000,4'h0)
      `CHIP_RESET
      // `LI_AOUT(16'h0000)
      `DRIVE_CMD(16'hFFFF,16'hAAAA,(16'h8000 + i),16'hFFFF,16'hAAAA,16'h0000,4'h0)
      `CHIP_RESET
      // `LI_AOUT(16'h0000)
      `DRIVE_CMD(16'h0001,16'hFFFF,(16'h8000 + i),16'h0001,16'hFFFF,16'h0000,4'h0)
      `CHIP_RESET
      // `LI_AOUT(16'h0000)
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
      `DRIVE_CMD(16'h7FFF,16'h0002,16'h8001,16'h7FFF,16'h0002,((export_disable) ? (16'h8001) : (16'h8001) ),4'h2)
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
      `DRIVE_CMD(16'hAAAA,16'h5555,16'h8002,16'hAAAA,16'h5555,((export_disable) ? (16'h5555) : (16'h5555) ),4'h2)
      `CHIP_NORMAL
      `DISPLAY_STATE
      `CHIP_NORMAL

      //////////////////////////////////////////////////////////
      //ALU MOVE LEFT NORMAL
      ///////////////////////////////////////////////////////////
      //TODO these might supposed to be liaot != 0?
      $display("MOVE LEFT");
      `LI_AOUT(16'h0000)
      `DRIVE_CMD_EVCMD(16'h5555,16'h0001,16'h8003,16'h0000,(export_disable ? 16'h0000 : 16'h0001),((export_disable) ? (16'h0000) : (16'h0000) ),4'h1)
      `CHIP_NORMAL
      `LI_AOUT(16'h0000)
      `DRIVE_CMD_EVCMD(16'hFFFF,16'hAAAA,16'h8003,16'h0000,(export_disable ? 16'h0000 : 16'hAAAA),((export_disable) ? (16'h0000) : (16'h0000) ),4'h1)
      `CHIP_NORMAL
      `LI_AOUT(16'h0000)
      `DRIVE_CMD_EVCMD(16'h0001,16'hFFFF,16'h8003,16'h0000,(export_disable ? 16'h0000 : 16'hFFFF),((export_disable) ? (16'h0000) : (16'h0000) ),4'h1)
      `CHIP_NORMAL
      `LI_AOUT(16'h0000)
      `DRIVE_CMD_EVCMD(16'hAAAA,16'h5555,16'h8003,16'h0000,(export_disable ? 16'h0000 : 16'h5555),((export_disable) ? (16'h0000) : (16'h0000) ),4'h1)
      `CHIP_NORMAL
      `DISPLAY_STATE

      //////////////////////////////////////////////////////////
      //ALU MOVE RIGHT
      ///////////////////////////////////////////////////////////
      $display("MOVE RIGHT");
      `LI_AOUT(16'h0001)
      `DRIVE_CMD_EVCMD(16'h5555,16'h0000,16'h8004,(export_disable ? 16'h0000 : 16'h5555),(export_disable ? 16'h0000 : 16'h0001),((export_disable) ? (16'h0000) : (16'h0001) ),4'h1)
      `CHIP_NORMAL
      `LI_AOUT(16'h0001)
      `DRIVE_CMD_EVCMD(16'hFFFF,16'hAAAA,16'h8004,(export_disable ? 16'h0000 : 16'hFFFF),(export_disable ? 16'h0000 : 16'h0001),((export_disable) ? (16'h0000) : (16'h0001) ),4'h1)
      `CHIP_NORMAL
      `LI_AOUT(16'h0001)
      `DRIVE_CMD_EVCMD(16'h0000,16'hFFFF,16'h8004,(export_disable ? 16'h0000 : 16'h0000),(export_disable ? 16'h0000 : 16'h0001),((export_disable) ? (16'h0000) : (16'h0001) ),4'h1)
      `CHIP_NORMAL
      `LI_AOUT(16'h0001)
      `DRIVE_CMD_EVCMD(16'hAAAA,16'h5555,16'h8004,(export_disable ? 16'h0000 : 16'hAAAA),(export_disable ? 16'h0000 : 16'h0001),((export_disable) ? (16'h0000) : (16'h0001) ),4'h1)
      `CHIP_NORMAL
      `DISPLAY_STATE

      //////////////////////////////////////////////////////////
      //SWAP
      ///////////////////////////////////////////////////////////
      $display("SWAP");;
      `LI_AOUT(16'h0001)
      `DRIVE_CMD_EVCMD(16'h5555,16'h0000,16'h8005,(export_disable ? 16'h0000 : 16'h0000),(export_disable ? 16'h0000 : 16'h5555),((export_disable) ? (16'h0000) : (16'h0001) ),4'h1)
      `CHIP_NORMAL
      `LI_AOUT(16'h0001)
      `DRIVE_CMD_EVCMD(16'hFFFF,16'hAAAA,16'h8005,(export_disable ? 16'h0000 : 16'hAAAA),(export_disable ? 16'h0000 : 16'hFFFF),((export_disable) ? (16'h0000) : (16'h0001) ),4'h1)
      `CHIP_NORMAL
      `LI_AOUT(16'h0001)
      `DRIVE_CMD_EVCMD(16'h0000,16'hFFFF,16'h8005,(export_disable ? 16'h0000 : 16'hFFFF),(export_disable ? 16'h0000 : 16'h0000),((export_disable) ? (16'h0000) : (16'h0001) ),4'h1)
      `CHIP_NORMAL
      `LI_AOUT(16'h0001)
      `DRIVE_CMD_EVCMD(16'hAAAA,16'h5555,16'h8005,(export_disable ? 16'h0000 : 16'h5555),(export_disable ? 16'h0000 : 16'hAAAA),((export_disable) ? (16'h0000) : (16'h0001) ),4'h1)
      `CHIP_NORMAL
      `DISPLAY_STATE

      //////////////////////////////////////////////////////////
      //ALU SHIFT LEFT 
      ///////////////////////////////////////////////////////////
      $display("SHIFT LEFT");
      `LI_AOUT(16'h0001)
      `DRIVE_CMD_EVCMD(16'h5555,16'h0000,16'h8006,(export_disable ? 16'h0000 : 16'h5555),(export_disable ? 16'h0000 : 16'h0000),((export_disable) ? (16'h0000) : (16'h5555) ),4'h1)
      `CHIP_NORMAL
      `LI_AOUT(16'h0001)
      `DRIVE_CMD_EVCMD(16'hFFFF,16'hAAAA,16'h8006,(export_disable ? 16'h0000 : 16'hFFFF),(export_disable ? 16'h0000 : 16'hAAAA),((export_disable) ? (16'h0000) : ((16'hFFFF) )<<16'hAAAA),4'h1)
      `CHIP_NORMAL
      `LI_AOUT(16'h0001)
      `DRIVE_CMD_EVCMD(16'h0000,16'hFFFF,16'h8006,(export_disable ? 16'h0000 : 16'h0000),(export_disable ? 16'h0000 : 16'hFFFF),((export_disable) ? (16'h0000) : ((16'h0000) )<<16'hFFFF),4'h1)
      `CHIP_NORMAL
      `LI_AOUT(16'h0001)
      `DRIVE_CMD_EVCMD(16'hAAAA,15'h5555,16'h8006,(export_disable ? 16'h0000 : 16'hAAAA),(export_disable ? 16'h0000 : 16'h5555),((export_disable) ? (16'h0000) : ((16'hAAAA) )<<16'h5555),4'h1)
      `CHIP_NORMAL
      `DISPLAY_STATE

      //////////////////////////////////////////////////////////
      //ALU SHIFT RIGHT 
      ///////////////////////////////////////////////////////////
      $display("SHIFT RIGHT");
      `LI_AOUT(16'h0001)
      `DRIVE_CMD_EVCMD(16'h5555,16'h0000,16'h8007,(export_disable ? 16'h0000 : 16'h5555),(export_disable ? 16'h0000 : 16'h0000),((export_disable) ? (16'h0000) : (16'h5555) ),4'h1)
      `CHIP_NORMAL
      `LI_AOUT(16'h0001)
      `DRIVE_CMD_EVCMD(16'hFFFF,16'hAAAA,16'h8007,(export_disable ? 16'h0000 : 16'hFFFF),(export_disable ? 16'h0000 : 16'hAAAA),((export_disable) ? (16'h0000) : ((16'hFFFF) )>>16'hAAAA),4'h1)
      `CHIP_NORMAL
      `LI_AOUT(16'h0001)
      `DRIVE_CMD_EVCMD(16'h0000,16'hFFFF,16'h8007,(export_disable ? 16'h0000 : 16'h0000),(export_disable ? 16'h0000 : 16'hFFFF),((export_disable) ? (16'h0000) : ((16'h0000) )>>16'hFFFF),4'h1)
      `CHIP_NORMAL
      `LI_AOUT(16'h0001)
      `DRIVE_CMD_EVCMD(16'hAAAA,16'h5555,16'h8007,(export_disable ? 16'h0000 : 16'hAAAA),(export_disable ? 16'h0000 : 16'h5555),((export_disable) ? (16'h0000) : ((16'hAAAA) )>>16'h5555),4'h1)
      `CHIP_NORMAL
      `DISPLAY_STATE
         


      // TODO have bad command with export_disable = 1 as well
      //////////////////////////////////////////////////////////
      // bad command
      ///////////////////////////////////////////////////////////
      $display("BAD CMD");
      for (logic [15:0] i =8; i <16; i++ ) begin
         `CHIP_NORMAL
         `LI_AOUT(16'h0001)
         `DRIVE_CMD_EVCMD(16'h0000,16'h5555,(16'h8000 + i),((export_disable) ? (16'h0000) : (16'h0000) ),(export_disable ? 16'h0000 : 16'h5555),(export_disable ? 16'h0000 : 16'h0001),4'h2)
         `CHIP_NORMAL
         `LI_AOUT(16'h0001)
         `DRIVE_CMD_EVCMD(16'hFFFF,16'hAAAA,(16'h8000 + i),((export_disable) ? (16'h0000) : (16'hFFFF) ),(export_disable ? 16'h0000 : 16'hAAAA),(export_disable ? 16'h0000 : 16'h0001),4'h2)
         `CHIP_NORMAL
         `LI_AOUT(16'hAAAA)
         `DRIVE_CMD_EVCMD(16'h0000,16'hFFFF,(16'h8000 + i),((export_disable) ? (16'h0000) : (16'h0000) ),(export_disable ? 16'h0000 : 16'hFFFF),(export_disable ? 16'h0000 : 16'hAAAA),4'h2)
         `CHIP_NORMAL
         `LI_AOUT(16'hFFFF)
         `DRIVE_CMD_EVCMD(16'hAAAA,16'h0001,(16'h8000 + i),((export_disable) ? (16'h0000) : (16'hAAAA) ),(export_disable ? 16'h0000 : 16'h0001),(export_disable ? 16'h0000 : 16'hFFFF),4'h2)
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