
// file: clk_wiz_0_3_1.v
// 
// (c) Copyright 2008 - 2013 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
//----------------------------------------------------------------------------
// User entered comments
//----------------------------------------------------------------------------
// None
//
//----------------------------------------------------------------------------
//  Output     Output      Phase    Duty Cycle   Pk-to-Pk     Phase
//   Clock     Freq (MHz)  (degrees)    (%)     Jitter (ps)  Error (ps)
//----------------------------------------------------------------------------
// clk_out1_72M____72.000______0.000______50.0______127.958____142.364
// clk_out2_144M___144.000______0.000______50.0______114.805____142.364
// clk_out3_12M____12.000______0.000______50.0______170.351____142.364
// clk_out4_72M____72.000______0.000______50.0______127.958____142.364
//
//----------------------------------------------------------------------------
// Input Clock   Freq (MHz)    Input Jitter (UI)
//----------------------------------------------------------------------------
// __primary_____________200____________0.010

`timescale 1ps/1ps

module clk_wiz_0_3_1_clk_wiz 

 (// Clock in ports
  // Clock out ports
  output        clk_out1_72M,
  output        clk_out2_144M,
  output        clk_out3_12M,
  output        clk_out4_72M,
  // Status and control signals
  input         resetn,
  output        locked,
  input         clk_in1_200M
 );
  // Input buffering
  //------------------------------------
wire clk_in1_200M_clk_wiz_0_3_1;
wire clk_in2_clk_wiz_0_3_1;
  assign clk_in1_200M_clk_wiz_0_3_1 = clk_in1_200M;




  // Clocking PRIMITIVE
  //------------------------------------

  // Instantiation of the MMCM PRIMITIVE
  //    * Unused inputs are tied off
  //    * Unused outputs are labeled unused

  wire        clk_out1_72M_clk_wiz_0_3_1;
  wire        clk_out2_144M_clk_wiz_0_3_1;
  wire        clk_out3_12M_clk_wiz_0_3_1;
  wire        clk_out4_72M_clk_wiz_0_3_1;
  wire        clk_out5_clk_wiz_0_3_1;
  wire        clk_out6_clk_wiz_0_3_1;
  wire        clk_out7_clk_wiz_0_3_1;

  wire [15:0] do_unused;
  wire        drdy_unused;
  wire        psdone_unused;
  wire        locked_int;
  wire        clkfbout_clk_wiz_0_3_1;
  wire        clkfbout_buf_clk_wiz_0_3_1;
  wire        clkfboutb_unused;
   wire clkout4_unused;
  wire        clkout5_unused;
  wire        clkout6_unused;
  wire        clkfbstopped_unused;
  wire        clkinstopped_unused;
  wire        reset_high;
  (* KEEP = "TRUE" *) 
  (* ASYNC_REG = "TRUE" *)
  reg  [7 :0] seq_reg1 = 0;
  (* KEEP = "TRUE" *) 
  (* ASYNC_REG = "TRUE" *)
  reg  [7 :0] seq_reg2 = 0;
  (* KEEP = "TRUE" *) 
  (* ASYNC_REG = "TRUE" *)
  reg  [7 :0] seq_reg3 = 0;
  (* KEEP = "TRUE" *) 
  (* ASYNC_REG = "TRUE" *)
  reg  [7 :0] seq_reg4 = 0;

  PLLE2_ADV
  #(.BANDWIDTH            ("OPTIMIZED"),
    .COMPENSATION         ("ZHOLD"),
    .STARTUP_WAIT         ("FALSE"),
    .DIVCLK_DIVIDE        (5),
    .CLKFBOUT_MULT        (36),
    .CLKFBOUT_PHASE       (0.000),
    .CLKOUT0_DIVIDE       (20),
    .CLKOUT0_PHASE        (0.000),
    .CLKOUT0_DUTY_CYCLE   (0.500),
    .CLKOUT1_DIVIDE       (10),
    .CLKOUT1_PHASE        (0.000),
    .CLKOUT1_DUTY_CYCLE   (0.500),
    .CLKOUT2_DIVIDE       (120),
    .CLKOUT2_PHASE        (0.000),
    .CLKOUT2_DUTY_CYCLE   (0.500),
    .CLKOUT3_DIVIDE       (20),
    .CLKOUT3_PHASE        (0.000),
    .CLKOUT3_DUTY_CYCLE   (0.500),
    .CLKIN1_PERIOD        (5.000))
  plle2_adv_inst
    // Output clocks
   (
    .CLKFBOUT            (clkfbout_clk_wiz_0_3_1),
    .CLKOUT0             (clk_out1_72M_clk_wiz_0_3_1),
    .CLKOUT1             (clk_out2_144M_clk_wiz_0_3_1),
    .CLKOUT2             (clk_out3_12M_clk_wiz_0_3_1),
    .CLKOUT3             (clk_out4_72M_clk_wiz_0_3_1),
    .CLKOUT4             (clkout4_unused),
    .CLKOUT5             (clkout5_unused),
     // Input clock control
    .CLKFBIN             (clkfbout_buf_clk_wiz_0_3_1),
    .CLKIN1              (clk_in1_200M_clk_wiz_0_3_1),
    .CLKIN2              (1'b0),
     // Tied to always select the primary input clock
    .CLKINSEL            (1'b1),
    // Ports for dynamic reconfiguration
    .DADDR               (7'h0),
    .DCLK                (1'b0),
    .DEN                 (1'b0),
    .DI                  (16'h0),
    .DO                  (do_unused),
    .DRDY                (drdy_unused),
    .DWE                 (1'b0),
    // Other control and status signals
    .LOCKED              (locked_int),
    .PWRDWN              (1'b0),
    .RST                 (reset_high));
  assign reset_high = ~resetn; 

  assign locked = locked_int;
// Clock Monitor clock assigning
//--------------------------------------
 // Output buffering
  //-----------------------------------

  BUFG clkf_buf
   (.O (clkfbout_buf_clk_wiz_0_3_1),
    .I (clkfbout_clk_wiz_0_3_1));







  BUFGCE clkout1_buf
   (.O   (clk_out1_72M),
    .CE  (seq_reg1[7]),
    .I   (clk_out1_72M_clk_wiz_0_3_1));

  BUFH clkout1_buf_en
   (.O   (clk_out1_72M_clk_wiz_0_3_1_en_clk),
    .I   (clk_out1_72M_clk_wiz_0_3_1));
  always @(posedge clk_out1_72M_clk_wiz_0_3_1_en_clk or posedge reset_high) begin
    if(reset_high == 1'b1) begin
	    seq_reg1 <= 8'h00;
    end
    else begin
        seq_reg1 <= {seq_reg1[6:0],locked_int};
  
    end
  end


  BUFGCE clkout2_buf
   (.O   (clk_out2_144M),
    .CE  (seq_reg2[7]),
    .I   (clk_out2_144M_clk_wiz_0_3_1));
 
  BUFH clkout2_buf_en
   (.O   (clk_out2_144M_clk_wiz_0_3_1_en_clk),
    .I   (clk_out2_144M_clk_wiz_0_3_1));
 
  always @(posedge clk_out2_144M_clk_wiz_0_3_1_en_clk or posedge reset_high) begin
    if(reset_high == 1'b1) begin
	  seq_reg2 <= 8'h00;
    end
    else begin
        seq_reg2 <= {seq_reg2[6:0],locked_int};
  
    end
  end


  BUFGCE clkout3_buf
   (.O   (clk_out3_12M),
    .CE  (seq_reg3[7]),
    .I   (clk_out3_12M_clk_wiz_0_3_1));
 
  BUFH clkout3_buf_en
   (.O   (clk_out3_12M_clk_wiz_0_3_1_en_clk),
    .I   (clk_out3_12M_clk_wiz_0_3_1));
 
  always @(posedge clk_out3_12M_clk_wiz_0_3_1_en_clk or posedge reset_high) begin
    if(reset_high == 1'b1) begin
	  seq_reg3 <= 8'h00;
    end
    else begin
        seq_reg3 <= {seq_reg3[6:0],locked_int};
  
    end
  end


  BUFGCE clkout4_buf
   (.O   (clk_out4_72M),
    .CE  (seq_reg4[7]),
    .I   (clk_out4_72M_clk_wiz_0_3_1));

  BUFH clkout4_buf_en
   (.O   (clk_out4_72M_clk_wiz_0_3_1_en_clk),
    .I   (clk_out4_72M_clk_wiz_0_3_1));
	
  always @(posedge clk_out4_72M_clk_wiz_0_3_1_en_clk or posedge reset_high) begin
    if(reset_high == 1'b1) begin
	  seq_reg4 <= 8'h00;
    end
    else begin
        seq_reg4 <= {seq_reg4[6:0],locked_int};
  
    end
  end





endmodule
