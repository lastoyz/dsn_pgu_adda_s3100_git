//Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Command: generate_target bd_fc5c_wrapper.bd
//Design : bd_fc5c_wrapper
//Purpose: IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module bd_fc5c_wrapper
   (Clk,
    FIT1_Toggle,
    GPIO1_tri_i,
    GPIO1_tri_o,
    INTC_IRQ,
    INTC_Interrupt,
    IO_addr_strobe,
    IO_address,
    IO_byte_enable,
    IO_read_data,
    IO_read_strobe,
    IO_ready,
    IO_write_data,
    IO_write_strobe,
    PIT1_Toggle,
    Reset);
  input Clk;
  output FIT1_Toggle;
  input [31:0]GPIO1_tri_i;
  output [31:0]GPIO1_tri_o;
  output INTC_IRQ;
  input [0:0]INTC_Interrupt;
  output IO_addr_strobe;
  output [31:0]IO_address;
  output [3:0]IO_byte_enable;
  input [31:0]IO_read_data;
  output IO_read_strobe;
  input IO_ready;
  output [31:0]IO_write_data;
  output IO_write_strobe;
  output PIT1_Toggle;
  input Reset;

  wire Clk;
  wire FIT1_Toggle;
  wire [31:0]GPIO1_tri_i;
  wire [31:0]GPIO1_tri_o;
  wire INTC_IRQ;
  wire [0:0]INTC_Interrupt;
  wire IO_addr_strobe;
  wire [31:0]IO_address;
  wire [3:0]IO_byte_enable;
  wire [31:0]IO_read_data;
  wire IO_read_strobe;
  wire IO_ready;
  wire [31:0]IO_write_data;
  wire IO_write_strobe;
  wire PIT1_Toggle;
  wire Reset;

  bd_fc5c bd_fc5c_i
       (.Clk(Clk),
        .FIT1_Toggle(FIT1_Toggle),
        .GPIO1_tri_i(GPIO1_tri_i),
        .GPIO1_tri_o(GPIO1_tri_o),
        .INTC_IRQ(INTC_IRQ),
        .INTC_Interrupt(INTC_Interrupt),
        .IO_addr_strobe(IO_addr_strobe),
        .IO_address(IO_address),
        .IO_byte_enable(IO_byte_enable),
        .IO_read_data(IO_read_data),
        .IO_read_strobe(IO_read_strobe),
        .IO_ready(IO_ready),
        .IO_write_data(IO_write_data),
        .IO_write_strobe(IO_write_strobe),
        .PIT1_Toggle(PIT1_Toggle),
        .Reset(Reset));
endmodule
