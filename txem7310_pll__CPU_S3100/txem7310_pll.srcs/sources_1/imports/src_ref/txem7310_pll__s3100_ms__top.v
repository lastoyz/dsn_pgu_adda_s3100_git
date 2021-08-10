// # this           : txem7310_pll__s3100_ms__top.v
// # top xdc        : txem7310_pll__s3100_ms__top.xdc
//
// # board          : S3100-CPU-BASE
// # board sch      : s3100_cpu_base_v100_20210413.pdf

// # note: artix-7 top design for S3100 CPU-BASE  master spi side
//
// ############################################################################
// ## TODO: bank usage in xc7a200
// ############################################################################
// # B13 : CPU_SPI, CPU_QSPI, CPU_ETH, FAN_SENS // (prev. in MC1/MC2) // 3.3V
// # B14 : CONF, LED, MTH_SPI control, CPU_GPIO                       // 1.8V
// # B15 : TP, LAN_SPI, SCIO, GPIB, BUS_BA                            // 3.3V
// # B16 : BUS_BD, BUS control, INTER_LOCK                            // 3.3V
// # B34 : MTH M0_SPI, MTH M1_SPI, HDR control         (prev. in MC1) // 3.3V
// # B35 : MTH M2_SPI, CAL_SPI, EXT_TRIG               (prev. in MC2) // 3.3V
// # B216: not used


// ## TODO: EP locations : LAN-MCS interface, MTH slave interface
//
// * LAN-MCS interface : MTH spi master emulation for debugging without connecting mother board
//                       - MSPI
//                       - TEST
//                       - MEM 
//                       - MCS
//
// * MTH slave SPI interface : END-POINT for test or known pattern


// ## S3100 MTH SPI frame format : 32 bits 
//
// * MOSI : 
//   FRAME MODE       // [1:0]
//   FRAME CONTROL    // [3:0]
//   FRAME ADDRESS    // [9:0]
//   FRAME WRITE DATA // [15:0]
//
// * MISO : 
//   zeros            // [1:0]
//   FRAME STATUS     // [3:0]
//   BOARD STATUS     // [7:0]
//   zeros            // [1:0]
//   FRAME READ DATA  // [15:0]


//// TODO: MTH slave SPI frame address map
// ## S3100-CPU-BASE  // GNDU --> PGU --> CPU-BASE(test only)
//                           
// +=======+===============+============+=========================================+================================+
// | Group | EP name       | frame adrs | type/index | Description                | contents (32-bit)              |
// |       |               | (10-bit)   |            |                            |                                |
// +=======+===============+============+============+============================+================================+
// | SSPI  | SSPI_TEST_WO  | 0x380      | wireout_E0 | Return known frame data.   | bit[31:16]=0x33AA              | 
// |       |               |            |            |                            | bit[15: 0]=0xCC55              |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TEST  | F_IMAGE_ID_WO | 0x080      | wireout_20 | Return FPGA image ID.      | Image_ID[31:0]                 |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+


//// TODO: ARM core host IO address map (16-bit register, 32-bit addressing)
// ## S3100-CPU-BASE  // GNDU --> PGU --> CPU-BASE(test only)
//                           
// +=======+===============+============+=========================================+================================+
// | Group | EP name       | IO adrs    | type/index | Description                | contents (32-bit)              |
// |       |               | (32-bit)   |            |                            |                                |
// +=======+===============+============+============+============================+================================+
// | MSPI  | MSPI_EN_CS_WI | 0x6060_0000| wire_in_16 | Control MSPI CS enable.    | bit[12: 0]=MSPI_EN_CS[12: 0]   |
// |       |               | 0x6060_0004|            |                            | bit[16]   =M0 group enable     |
// |       |               |            |            |                            | bit[17]   =M1 group enable     |
// |       |               |            |            |                            | bit[18]   =M2 group enable     |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MSPI  | MSPI_CON_WI   | 0x6070_0000| wire_in_17 | Control MSPI MOSI frame.   | bit[31:26]=frame_data_C[ 5:0]  |
// |       |               | 0x6070_0004|            |                            | bit[25:16]=frame_data_A[ 9:0]  |
// |       |               |            |            |                            | bit[15: 0]=frame_data_D[15:0]  |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MSPI  | MSPI_FLAG_WO  | 0x6070_0008| wireout_24 | Return MSPI MISO frame.    | bit[31:16]=frame_data_E[15:0]  |
// |       |               | 0x6070_000C|            |                            | bit[15: 0]=frame_data_B[15:0]  |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MSPI  | MSPI_TI       | 0x6070_0010| trig_in_42 | Trigger functions.         | bit[0]=trigger_reset           |
// |       |               |            |            |                            | bit[1]=trigger_init            |
// |       |               |            |            |                            | bit[2]=trigger_frame           |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MSPI  | MSPI_TO       | 0x6070_0018| trigout_62 | Check if trigger is done.  | bit[0]=done_reset              |
// |       |               |            |            |                            | bit[1]=done_init               |
// |       |               |            |            |                            | bit[2]=done_frame              |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TEST  | F_IMAGE_ID_WO | 0x6060_0080| wireout_20 | TBC                        | TBC                            |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TEST  | TIMESTAMP_WO  | 0x6060_0088| wireout_22 | TBC                        | TBC                            |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TEST  | XADC_TEMP_WO  | 0x6060_0090| wireout_3A | TBC                        | TBC                            |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TEST  | XADC_VOLT_WO  | 0x6060_0098| wireout_3B | TBC                        | TBC                            |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TEST  | BRD_CON_WI    | 0x6060_00A0| wire_in_03 | TBC                        | TBC                            |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TEST  | TEST_CON_WI   | 0x6070_0040| wire_in_01 | TBC                        | TBC                            |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TEST  | TEST_OUT_WO   | 0x6070_0048| wireout_21 | TBC                        | TBC                            |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TEST  | TEST_TI       | 0x6070_0050| trig_in_40 | TBC                        | TBC                            |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TEST  | TEST_TO       | 0x6070_0058| trigout_60 | TBC                        | TBC                            |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MEM   | MEM_WI_WI     | 0x6070_0080| wire_in_13 | TBC                        | TBC                            |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MEM   | MEM_FDAT_WI   | 0x6070_0088| wire_in_12 | TBC                        | TBC                            |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MEM   | MEM_TI        | 0x6070_0090| trig_in_53 | TBC                        | TBC                            |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MEM   | MEM_TO        | 0x6070_0098| trigout_73 | TBC                        | TBC                            |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MEM   | MEM_PI        | 0x6070_00A0| pipe_in_93 | TBC                        | TBC                            |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MEM   | MEM_PO        | 0x6070_00A8| pipeout_B3 | TBC                        | TBC                            |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | SSPI  | SSPI_CON_WI   | 0x6060_00A8| wire_in_02 | TBC                        | TBC                            |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | SSPI  | SSPI_FLAG_WO  | 0x6060_00B0| wireout_23 | TBC                        | TBC                            |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | ____  | ERR_LED_WI    | 0x6070_0018| wire_in_1A | control ERR_LED.           | TBC                            |
// | ____  | FPGA_LED_WI   | 0x6010_0010| wire_in_1B | Control FPGA_LED.          | TBC                            |
// | ____  | HDL_OUT_WI    | 0x6010_0030| wire_in_1C | Control HDL I/F OUT.       | TBC                            |
// | ____  | INTERLOCK_WI  | 0x6010_0068| wire_in_1D | Control INTER_LOCK.        | {INT_LOCK RELAY, INT_LOCK LED} |
// | ____  | GPIB_CON_WI   | 0x6030_0010| wire_in_1E | Control GPIB               | TBC                            |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | ____  | MAGIC_CODE_WO | 0x6010_0000| wireout_30 | Read knonwn code.          | {MAGIC CODE_H, MAGIC CODE_L}   |
// | ____  | LAN_STAT_WO   | 0x6010_0018| wireout_31 | Read LAN status.           | {MASTER MODE, LAN IP Address}  |
// | ____  | F_IMG_ID_WO   | 0x6010_0020| wireout_32 | Read FPGA IMAGE ID.        | {F_IMAGE_ID_H, F_IMAGE_ID_L}   |
// | ____  | HDL_IN_WO     | 0x6010_0038| wireout_33 | Read Handler inputs.       | HDL I/F IN                     |
// | ____  | FAN_SPD_A_WO  | 0x6010_0040| wireout_34 | Read FAN speed.            | {FAN#1 SPEED, FAN#0 SPEED}     |
// | ____  | FAN_SPD_B_WO  | 0x6010_0048| wireout_35 | Read FAN speed.            | {FAN#3 SPEED, FAN#2 SPEED}     |
// | ____  | FAN_SPD_C_WO  | 0x6010_0050| wireout_36 | Read FAN speed.            | {FAN#5 SPEED, FAN#4 SPEED}     |
// | ____  | FAN_SPD_D_WO  | 0x6010_0058| wireout_37 | Read FAN speed.            | {FAN#7 SPEED, FAN#6 SPEED}     |
// | ____  | INTERLOCK_WO  | 0x6010_0060| wireout_38 | Read INTER_LOCK.           | TBC                            |
// | ____  | GPIB_STAT_WO  | 0x6030_0000| wireout_39 | Read GPIB status.          | GPIB_STATUS     |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | ____  | RESET_TI      | 0x6010_0028| trig_in_50 | Trigger S/W Reset.         | TBC                            |
// | ____  | TRIG_TI       | 0x60A0_0000| trig_in_51 | Trigger TRIG pulses.       | {PRE_Trig, Trig}               |
// | ____  | SOT_TI        | 0x60A0_0008| trig_in_52 | Trigger SOT pulses.        | TBC                            |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+


//// TODO: LAN-MCS endpoint address map
// ## S3100-CPU-BASE  // GNDU --> PGU --> CPU-BASE
//
// note: LAN access must have TEST, MCS, MEM and MSPI.
// note: MEM device is connected via pin B34_L5N, net S_IO_0 in case of S3100-PGU and S3000-PGU.
// note: MEM device is connected via pin IO_L11P_T1_SRCC_15, net SCIO_0 in case of S3100-CPU-BASE.
//
// +=======+===============+============+=========================================+================================+
// | Group | EP name       | MCS adrs   | type/index | Description                | contents (32-bit)              |
// |       |               | (32-bit)   |            |                            |                                |
// +=======+===============+============+=========================================+================================+
// | TEST  | F_IMAGE_ID_WO | TBD        | wireout_20 | Return FPGA image ID.      | Image_ID[31:0]                 | 
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TEST  | XADC_TEMP_WO  | TBD        | wireout_3A | Return XADC values.[mC]    | MON_TEMP[31:0]                 | 
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TEST  | XADC_VOLT_WO  | TBD        | wireout_3B | Return XADC values.[mV]    | MON_VOLT[31:0] normial 1.1V    |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TEST  | TIMESTAMP_WO  | TBD        | wireout_22 | Return time stamp. (10MHz) | TIME_STAMP[31:0]               | 
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TEST  | TEST_MON_WO   | TBD        | wireout_23 | Return PLL status.         | bit[18]=MCS pll locked         | 
// |       |               |            |            |                            | bit[24]=DAC common pll locked  |
// |       |               |            |            |                            | bit[25]=DAC0 pll locked        |
// |       |               |            |            |                            | bit[26]=DAC1 pll locked        |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TEST  | TEST_CON_WI   | TBD        | wireout_01 | Control test logics.       | bit[0]=count1_reset            | 
// |       |               |            |            |                            | bit[1]=count1_disable          |
// |       |               |            |            |                            | bit[2]=count2_auto_increase    |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TEST  | TEST_OUT_WO   | TBD        | wireout_21 | Return test values.        | bit[15:8]=count2[7:0]          |
// |       |               |            |            |                            | bit[ 7:0]=count1[7:0]          |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TEST  | TEST_TI       | TBD        | wireout_40 | Trigger test functions.    | bit[0]=trigger_count2_reset    |
// |       |               |            |            |                            | bit[1]=trigger_count2_up       |
// |       |               |            |            |                            | bit[2]=trigger_count2_down     |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TEST  | TEST_TO       | TBD        | wireout_60 | Check if trigger is done.  | bit[ 0]=done_count1eq00        |
// |       |               |            |            |                            | bit[ 1]=done_count1eq80        |
// |       |               |            |            |                            | bit[16]=done_count2eqFF        |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TEST  | TEST_PI       | TBD__      | pipe_in_8A | Write data into test FIFO. | test_fifo_data[31:0]           |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TEST  | TEST_PO       | TBD__      | pipeout_AA | Read data from test FIFO.  | test_fifo_data[31:0]           |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TEST  | BRD_CON_WI    | TBD        | wire_in_03 | Control board from LAN.    | bit[ 0]=HW_reset               | 
// |       |               |            |            |                            | bit[ 8]=mcs_ep_po_enable       |
// |       |               |            |            |                            | bit[ 9]=mcs_ep_pi_enable       |
// |       |               |            |            |                            | bit[10]=mcs_ep_to_enable       |
// |       |               |            |            |                            | bit[11]=mcs_ep_ti_enable       |
// |       |               |            |            |                            | bit[12]=mcs_ep_wo_enable       |
// |       |               |            |            |                            | bit[13]=mcs_ep_wi_enable       |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MCS   | MCS_SETUP_WI  | TBD        | wire_in_19 | Control board for MCS.     | bit[31:16]=board_id[15:0]      | 
// |       |               |            |            |                            | bit[10]=lan_on_base_enable(NA) |
// |       |               |            |            |                            | bit[ 9]=eeprom_on_tp_enable(NA)|
// |       |               |            |            |                            | bit[ 8]=eeprom_lan_enable(NA)  |
// |       |               |            |            |                            | bit[ 7: 0]=slot_id             |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MSPI  | MSPI_EN_CS_WI | TBD        | wire_in_16 | Control MSPI CS enable.    | bit[12: 0]=MSPI_EN_CS[12: 0]   |
// |       |               |            |            |                            | bit[16]   =M0 group enable     |
// |       |               |            |            |                            | bit[17]   =M1 group enable     |
// |       |               |            |            |                            | bit[18]   =M2 group enable     |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MSPI  | MSPI_CON_WI   | TBD        | wire_in_17 | Control MSPI MOSI frame.   | bit[31:26]=frame_data_C[ 5:0]  |
// |       |               |            |            |                            | bit[25:16]=frame_data_A[ 9:0]  |
// |       |               |            |            |                            | bit[15: 0]=frame_data_D[15:0]  |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MSPI  | MSPI_FLAG_WO  | TBD        | wireout_24 | Return MSPI MISO frame.    | bit[31:16]=frame_data_E[15:0]  |
// |       |               |            |            |                            | bit[15: 0]=frame_data_B[15:0]  |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MSPI  | MSPI_TI       | TBD        | trig_in_42 | Trigger functions.         | bit[0]=trigger_reset           |
// |       |               |            |            |                            | bit[1]=trigger_init            |
// |       |               |            |            |                            | bit[2]=trigger_frame           |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MSPI  | MSPI_TO       | TBD        | trigout_62 | Check if trigger is done.  | bit[0]=done_reset              |
// |       |               |            |            |                            | bit[1]=done_init               |
// |       |               |            |            |                            | bit[2]=done_frame              |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MEM   | MEM_WI        | TBD__      | wire_in_13 | Control EEPROM interface.  | bit[  15]=disable_SBP_packet   | 
// |       |               |            |            |                            | bit[11:0]=num_bytes_DAT[11:0]  |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MEM   | MEM_FDAT_WI   | TBD__      | wire_in_12 | Control EEPROM frame data. | bit[31:24]=frame_data_ADH[7:0] |
// |       |               |            |            |                            | bit[23:16]=frame_data_ADL[7:0] |
// |       |               |            |            |                            | bit[15: 8]=frame_data_STA[7:0] |
// |       |               |            |            |                            | bit[ 7: 0]=frame_data_CMD[7:0] |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MEM   | MEM_TI        | TBD__      | trig_in_53 | Trigger functions.         | bit[0]=trigger_reset           |
// |       |               |            |            |                            | bit[1]=trigger_fifo_reset      |
// |       |               |            |            |                            | bit[2]=trigger_frame           |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MEM   | MEM_TO        | TBD__      | trigout_73 | Check status.              | bit[0]=MEM_valid_latch         |
// |       |               |            |            |                            | bit[1]=done_frame_latch        |
// |       |               |            |            |                            | bit[2]=done_frame (one pulse)  |
// |       |               |            |            |                            | bit[15:8]=frame_data_STA[7:0]  |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MEM   | MEM_PI        | TBD__      | pipe_in_93 | Write data into pipe.      | bit[7:0]=frame_data_DAT_w[7:0] |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MEM   | MEM_PO        | TBD__      | pipeout_B3 | Read data from pipe.       | bit[7:0]=frame_data_DAT_r[7:0] |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+


`timescale 1ns / 1ps
//`default_nettype none // for setup test


//// TODO: submodule rpm counter //{

//$$ note RPM counter 
//$$ count per 60 sec ... @ 10MHz ... 60 sec * 10MHz = 600_000_000 ~ 2^29.16
//$$ 60 * count per  1 sec ... @ 10MHz ... 1  sec * 10MHz =  10_000_000 ~ 2^23.25

module rpm_counter ( //{
	// for common 
	input  wire        clk     , // 10MHz
	input  wire        reset_n ,	

	input  wire        i_pulse   , // pulse input
	output wire [15:0] o_rpm_count
);

reg [15:0] r_rpm_count;
reg [15:0] r_cnt_pulse;
reg [32:0] r_count_down_1sec;
reg [1:0]  r_smp_pulse;
wire w_rise_pulse = (~r_smp_pulse[1]) & (r_smp_pulse[0]);


always @(posedge clk, negedge reset_n) begin
	if (!reset_n) begin
		r_rpm_count       <= 16'b0;
		r_cnt_pulse       <= 16'b0;
		r_count_down_1sec <= 32'd10_000_000 - 1;
		r_smp_pulse       <= 2'b0;
	end
	else begin
		//
		if (r_count_down_1sec==0) begin
			r_rpm_count       <= 60 * r_cnt_pulse;
			r_cnt_pulse       <= 16'b0;
			r_count_down_1sec <= 32'd10_000_000 - 1;
		end
		else begin
			r_cnt_pulse       <= (w_rise_pulse)? r_cnt_pulse+1 : r_cnt_pulse;
			r_count_down_1sec <= r_count_down_1sec - 1;
		end
		//
		r_smp_pulse <= {r_smp_pulse[0], i_pulse};
		//
		//
	end
end

assign o_rpm_count = r_rpm_count;

endmodule //}


//// testbench
module tb_rpm_counter (); //{

//// clocks //{
reg clk_10M = 1'b0; // assume 10MHz or 100ns
	always
	#50 	clk_10M = ~clk_10M; // toggle every 50ns --> clock 100ns 
//
reg reset_n = 1'b0;
wire reset = ~reset_n;
//
reg clk_100 = 1'b0; // assume 100Hz or 10 000 000ns
	always
	#5000000 	clk_100 = ~clk_100; // toggle
	
wire sys_clk  = clk_10M;
wire test_clk = clk_100;
	
//}


//// DUT //{

rpm_counter rpm_counter__inst0 (
	.clk         (sys_clk),
	.reset_n     (reset_n),
	.i_pulse     (test_clk),
	.o_rpm_count () 
);

//}

//// test sequence //{

initial begin : reset_n__gen
#0	reset_n 	= 1'b0;
#200;
	reset_n 	= 1'b1; 
#200;

#1000_000_000;
#1000_000_000;
$finish;
end

//}

endmodule //}

//}


/* top module integration */
module txem7310_pll__s3100_ms__top ( 
	
	//// note: BANK 14 15 16  signals // NOT compatible with TXEM7310 connectors
	

	//// BANK B14 //{
	
	// # IO_0_14                       # P20  # NA                        
	// # IO_B14_L1P_D00_MOSI           # P22  # FPGA_CFG_D0     (*)       
	// # IO_B14_L1N_D01_DIN            # R22  # FPGA_CFG_D1     (*)       
	// # IO_B14_L2P_D02                # P21  # FPGA_CFG_D2     (*)       
	// # IO_B14_L2N_D03                # R21  # FPGA_CFG_D3     (*)       
	// # IO_B14_L3P_PUDC_B             # U22  # FPGA_CFG_PUDC_B (*)       
	// # IO_B14_L3N                    # V22  # NA                        
	                                                             
	output wire  o_B14_L4P        , // # T21  # FPGA_IO0                  
	output wire  o_B14_L4N        , // # U21  # FPGA_IO1                  
	output wire  o_B14_L5P        , // # P19  # FPGA_IO2                  
	output wire  o_B14_L5N        , // # R19  # FPGA_IO3                  
	                                                            
	// # IO_B14_L6P_FCS_B              # T19  # FPGA_CFG_FCS_B  (*)       
	                                                            
	output wire  o_B14_L6N        , // # T20  # FPGA_IO4                  
	output wire  o_B14_L7P        , // # W21  # FPGA_IO5                  
	output wire  o_B14_L7N        , // # W22  # FPGA_MBD_RS_422_SPI_EN    
	output wire  o_B14_L8P        , // # AA20 # FPGA_MBD_RS_422_TRIG_EN   
	                                                       
	output wire  o_B14_L8N        , // # AA21 # FPGA_M0_SPI_TX_EN         
	output wire  o_B14_L9P        , // # Y21  # FPGA_M1_SPI_TX_EN         
	output wire  o_B14_L9N        , // # Y22  # FPGA_M2_SPI_TX_EN         
	output wire  o_B14_L10P       , // # AB21 # FPGA_TRIG_TX_EN           
								 		 
	// # IO_B14_L10N_                  # AB22 # NA                        
								 		 
	inout  wire  io_B14_L11P_SRCC , // # U20  # FPGA_LED0  //$$ led                
	inout  wire  io_B14_L11N_SRCC , // # V20  # FPGA_LED1  //$$ led                
	inout  wire  io_B14_L12P_MRCC , // # W19  # FPGA_LED2  //$$ led                
	inout  wire  io_B14_L12N_MRCC , // # W20  # FPGA_LED3  //$$ led                
	inout  wire  io_B14_L13P_MRCC , // # Y18  # FPGA_LED4  //$$ led                
	inout  wire  io_B14_L13N_MRCC , // # Y19  # FPGA_LED5  //$$ led                
	inout  wire  io_B14_L14P_SRCC , // # V18  # FPGA_LED6  //$$ led                
	inout  wire  io_B14_L14N_SRCC , // # V19  # FPGA_LED7  //$$ led                
								 		 
	// # IO_B14_L15P                   # AA19 # NA                        
	// # IO_B14_L15N                   # AB20 # NA                        
	// # IO_B14_L16P                   # V17  # NA                        
								 		 
	output wire  o_B14_L16N       , // # W17  # FPGA_GPIO_PB5             
	output wire  o_B14_L17P       , // # AA18 # FPGA_GPIO_PC4             
	output wire  o_B14_L17N       , // # AB18 # FPGA_GPIO_PC5             
	output wire  o_B14_L18P       , // # U17  # FPGA_GPIO_PH4             
	output wire  o_B14_L18N       , // # U18  # FPGA_GPIO_PH6             
	output wire  o_B14_L19P       , // # P14  # FPGA_GPIO_PH7             
				 				 		 
	output wire  o_B14_L19N       , // # R14  # FPGA_GPIO_PC9             
	output wire  o_B14_L20P       , // # R18  # FPGA_GPIO_PC10            
	output wire  o_B14_L20N       , // # T18  # FPGA_GPIO_PC11            
	output wire  o_B14_L21P       , // # N17  # FPGA_GPIO_PC12            
	output wire  o_B14_L21N       , // # P17  # FPGA_GPIO_PC13            
	output wire  o_B14_L22P       , // # P15  # FPGA_GPIO_PC14            
	output wire  o_B14_L22N       , // # R16  # FPGA_GPIO_PC15            
				 				 		 
	input  wire  i_B14_L23P       , // # N13  # FPGA_GPIO_PD2             
	input  wire  i_B14_L23N       , // # N14  # FPGA_GPIO_PI8             
	input  wire  i_B14_L24P       , // # P16  # FPGA_GPIO_PA8             
	input  wire  i_B14_L24N       , // # R17  # FPGA_GPIO_PB11            
								  		 
	// # IO_B14_25                     # N15  # NA                        
	
	//}

	
	//// BANK B15 //{
	
	output wire   o_B15_0_        , // # J16  # F_RDY

	// ## TPs and EXT_I2C
	output wire  o_B15_L1P_AD0P   , // # H13  # F_TP0 
	output wire  o_B15_L1N_AD0N   , // # G13  # F_TP1 
	output wire  o_B15_L2P_AD8P   , // # G15  # F_TP2 
	output wire  o_B15_L2N_AD8N   , // # G16  # F_TP3 
	output wire  o_B15_L3P_AD1P   , // # J14  # F_TP4 
	output wire  o_B15_L3N_AD1N   , // # H14  # F_TP5 
	//                                        
	input  wire  i_B15_L4P        , // # G17  # EXT_I2C_4_SCL
	inout  wire io_B15_L4N        , // # G18  # EXT_I2C_4_SDA
	//                                        
	output wire  o_B15_L5P_AD9P   , // # J15  # F_TP6 
	output wire  o_B15_L5N_AD9N   , // # H15  # F_TP7 
								   
	// ## LAN for END-POINTS       
	output wire  o_B15_L6P        , // # H17  # LAN_PWDN 
	output wire  o_B15_L6N        , // # H18  # LAN_SSAUX_B //$$ ssn aux
	output wire  o_B15_L7P        , // # J22  # LAN_MOSI
	output wire  o_B15_L7N        , // # H22  # LAN_SCLK
	output wire  o_B15_L8P        , // # H20  # LAN_SSN_B
	input  wire  i_B15_L8N        , // # G20  # LAN_INT_B
	output wire  o_B15_L9P        , // # K21  # LAN_RST_B
	input  wire  i_B15_L9N        , // # K22  # LAN_MISO
	
	// ## ADC
	//input  wire i_B15_L10P_AD11P, // # M21  # AUX_AD11P
	//input  wire i_B15_L10N_AD11N, // # L21  # AUX_AD11N

	inout  wire io_B15_L11P_SRCC  , // # J20  # SCIO_0 //$$ 11AA160T
	inout  wire io_B15_L11N_SRCC  , // # J21  # SCIO_1 //$$ 11AA160T

	input  wire  i_B15_L12P_MRCC  , // # J19  # GPIB_IRQ      
	output wire  o_B15_L12N_MRCC  , // # H19  # GPIB_nCS      
	output wire  o_B15_L13P_MRCC  , // # K18  # GPIB_nRESET   
	output wire  o_B15_L13N_MRCC  , // # K19  # GPIB_SW_nOE   
	input  wire  i_B15_L14P_SRCC  , // # L19  # GPIB_REM      
	input  wire  i_B15_L14N_SRCC  , // # L20  # GPIB_TADCS    
	input  wire  i_B15_L15P       , // # N22  # GPIB_LADCS    
	input  wire  i_B15_L15N       , // # M22  # GPIB_DCAS     
	input  wire  i_B15_L16P       , // # M18  # GPIB_TRIG     
	output wire  o_B15_L16N       , // # L18  # GPIB_DATA_DIR 
	output wire  o_B15_L17P       , // # N18  # GPIB_DATA_nOE 

	//input  wire i_B15_L17N,       // # N19  # NA
							        
	input  wire  i_B15_L18P       , // # N20  # BA25
	input  wire  i_B15_L18N       , // # M20  # BA24
	input  wire  i_B15_L19P       , // # K13  # BA23
	input  wire  i_B15_L19N       , // # K14  # BA22
	input  wire  i_B15_L20P       , // # M13  # BA21
	input  wire  i_B15_L20N       , // # L13  # BA20
	input  wire  i_B15_L21P       , // # K17  # BA19
	input  wire  i_B15_L21N       , // # J17  # BA18
	input  wire  i_B15_L22P       , // # L14  # BA7
	input  wire  i_B15_L22N       , // # L15  # BA6
	input  wire  i_B15_L23P       , // # L16  # BA5
	input  wire  i_B15_L23N       , // # K16  # BA4
	input  wire  i_B15_L24P       , // # M15  # BA3
	input  wire  i_B15_L24N       , // # M16  # BA2

	input  wire  i_B15_25         , // # M17  # BUF_FMC_CLK

	//}


	//// BANK B16 //{
	
	output wire  o_B16_0_         , // # F15  # BASE_F_LED_ERR 
	
	inout  wire io_B16_L1P        , // # F13  # BD0
	inout  wire io_B16_L1N        , // # F14  # BD1
	inout  wire io_B16_L2P        , // # F16  # BD2
	inout  wire io_B16_L2N        , // # E17  # BD3
	inout  wire io_B16_L3P        , // # C14  # BD4
	inout  wire io_B16_L3N        , // # C15  # BD5
	inout  wire io_B16_L4P        , // # E13  # BD6
	inout  wire io_B16_L4N        , // # E14  # BD7
	inout  wire io_B16_L5P        , // # E16  # BD8
	inout  wire io_B16_L5N        , // # D16  # BD9
	inout  wire io_B16_L6P        , // # D14  # BD10
	inout  wire io_B16_L6N        , // # D15  # BD11
	inout  wire io_B16_L7P        , // # B15  # BD12
	inout  wire io_B16_L7N        , // # B16  # BD13
	inout  wire io_B16_L8P        , // # C13  # BD14
	inout  wire io_B16_L8N        , // # B13  # BD15
	inout  wire io_B16_L9P        , // # A15  # BD16
	inout  wire io_B16_L9N        , // # A16  # BD17
	inout  wire io_B16_L10P       , // # A13  # BD18
	inout  wire io_B16_L10N       , // # A14  # BD19
	inout  wire io_B16_L11P       , // # B17  # BD20
	inout  wire io_B16_L11N       , // # B18  # BD21
	inout  wire io_B16_L12P       , // # D17  # BD22
	inout  wire io_B16_L12N       , // # C17  # BD23
	inout  wire io_B16_L13P       , // # C18  # BD24
	inout  wire io_B16_L13N       , // # C19  # BD25
	inout  wire io_B16_L14P       , // # E19  # BD26
	inout  wire io_B16_L14N       , // # D19  # BD27
	inout  wire io_B16_L15P       , // # F18  # BD28
	inout  wire io_B16_L15N       , // # E18  # BD29
	inout  wire io_B16_L16P       , // # B20  # BD30
	inout  wire io_B16_L16N       , // # A20  # BD31
	
	//  # IO_B16_L17P_T2_16         // # A18  # NA

	output wire  o_B16_L17N       , // # A19  # BUF_DATA_DIR
	output wire  o_B16_L18P       , // # F19  # nBUF_DATA_OE

	//  # IO_B16_L18N_T2_16         // # F20  # NA

	output wire  o_B16_L19P       , // # D20  # INTER_RELAY_O
	output wire  o_B16_L19N       , // # C20  # INTER_LED_O
	input  wire  i_B16_L20P       , // # C22  # INTER_LOCK_ON

	//  # IO_B16_L20N_T3_16         // # B22  # NA

	input  wire  i_B16_L21P       , // # B21  # nBNE1
	input  wire  i_B16_L21N       , // # A21  # nBNE2
	input  wire  i_B16_L22P       , // # E22  # nBNE3
	input  wire  i_B16_L22N       , // # D22  # nBNE4
	input  wire  i_B16_L23P       , // # E21  # nBOE
	input  wire  i_B16_L23N       , // # D21  # nBWE
	
	//  # IO_B16_L24P_T3_16         // # G21  # NA
	
	input  wire  i_B16_L24N       , // # G22  # BUF_nRESET											
	output wire  o_B16_25         , // # F21  # RUN_FPGA_LED
	
	//}
	


	//// BANK B13 //{
	
	// # IO_B13_0_                , // # Y17  # NA
											  
	input  wire  i_B13_L1P        , // # Y16  # SPI__1_SCLK
	input  wire  i_B13_L1N        , // # AA16 # SPI__1_nCS
	input  wire  i_B13_L2P        , // # AB16 # SPI__1_MOSI
	output wire  o_B13_L2N        , // # AB17 # SPI__1_MISO

	input  wire  i_B13_L3P        , // # AA13   # SPI__2_SCLK
	input  wire  i_B13_L3N        , // # AB13   # SPI__2_nCS
	input  wire  i_B13_L4P        , // # AA15   # SPI__2_MOSI
	output wire  o_B13_L4N        , // # AB15   # SPI__2_MISO

	input  wire  i_B13_L5P        , // # Y13    # QSPI_BK1_NCS
	input  wire  i_B13_L5N        , // # AA14   # QSPI_CLK
	inout  wire io_B13_L6P        , // # W14    # QSPI_BK1_IO0
	inout  wire io_B13_L6N        , // # Y14    # QSPI_BK1_IO1
	inout  wire io_B13_L7P        , // # AB11   # QSPI_BK1_IO2
	inout  wire io_B13_L7N        , // # AB12   # QSPI_BK1_IO3

	// # IO_B13_L8P               , // # AA9    # NA

	input  wire  i_B13_L8N        , // # AB10   # ETH_nIRQ
	output wire  o_B13_L9P        , // # AA10   # ETH_nRESET
	output wire  o_B13_L9N        , // # AA11   # ETH_nCS
	input  wire  i_B13_L10P       , // # V10    # ETH_nLINKLED
	input  wire  i_B13_L10N       , // # W10    # ETH_nTXLED
	input  wire  i_B13_L11P_SRCC  , // # Y11    # ETH_nRXLED

	// # IO_B13_L11N_SRCC         , // # Y12    # NA

	// # IO_B13_L12P_MRCC         , // # W11    # clocks sys_clkp (*)
	// # IO_B13_L12N_MRCC         , // # W12    # clocks sys_clkn (*)

	input  wire  i_B13_L13P_MRCC  , // # V13    # SYNC_10MHz
	input  wire  i_B13_L13N_MRCC  , // # V14    # EXT_TRIG_IN_CW

	input  wire  i_B13_L14P_SRCC  , // # U15    # FPGA_FAN_SENS_0
	input  wire  i_B13_L14N_SRCC  , // # V15    # FPGA_FAN_SENS_1
	input  wire  i_B13_L15P       , // # T14    # FPGA_FAN_SENS_2
	input  wire  i_B13_L15N       , // # T15    # FPGA_FAN_SENS_3
	input  wire  i_B13_L16P       , // # W15    # FPGA_FAN_SENS_4
	input  wire  i_B13_L16N       , // # W16    # FPGA_FAN_SENS_5
	input  wire  i_B13_L17P       , // # T16    # FPGA_FAN_SENS_6
	input  wire  i_B13_L17N       , // # U16    # FPGA_FAN_SENS_7

	//}
	
	
	//// BANK B34 //{
	
	input  wire  i_B34_0_         , // # T3     # FPGA_EXT_TRIG_IN_D
											    
	output wire  o_B34_L1P        , // # T1     # FPGA_M0_SPI_nCS0
	output wire  o_B34_L1N        , // # U1     # FPGA_M0_SPI_nCS1
	output wire  o_B34_L2P        , // # U2     # FPGA_M0_SPI_nCS2
	output wire  o_B34_L2N        , // # V2     # FPGA_M0_SPI_nCS3
	output wire  o_B34_L3P        , // # R3     # FPGA_M0_SPI_nCS4
	output wire  o_B34_L3N        , // # R2     # FPGA_M0_SPI_nCS5
	output wire  o_B34_L4P        , // # W2     # FPGA_M0_SPI_nCS6
	output wire  o_B34_L4N        , // # Y2     # FPGA_M0_SPI_nCS7
	output wire  o_B34_L5P        , // # W1     # FPGA_M0_SPI_nCS8
	output wire  o_B34_L5N        , // # Y1     # FPGA_M0_SPI_nCS9
	output wire  o_B34_L6P        , // # U3     # FPGA_M0_SPI_nCS10
	output wire  o_B34_L6N        , // # V3     # FPGA_M0_SPI_nCS11
	output wire  o_B34_L7P        , // # AA1    # FPGA_M0_SPI_nCS12
											    
	output wire  o_B34_L7N        , // # AB1    # M0_SPI_TX_CLK
	output wire  o_B34_L8P        , // # AB3    # M0_SPI_MOSI
	input  wire  i_B34_L8N        , // # AB2    # M0_SPI_RX_CLK
	input  wire  i_B34_L9P        , // # Y3     # M0_SPI_MISO
	
	//  # IO_B34_L9N              , // # AA3    # NA
	
	output wire  o_B34_L10P       , // # AA5    # FPGA_M1_SPI_nCS0
	output wire  o_B34_L10N       , // # AB5    # FPGA_M1_SPI_nCS1
	output wire  o_B34_L11P_SRCC  , // # Y4     # FPGA_M1_SPI_nCS2
	output wire  o_B34_L11N_SRCC  , // # AA4    # FPGA_M1_SPI_nCS3
	output wire  o_B34_L12P_MRCC  , // # V4     # FPGA_M1_SPI_nCS4
	output wire  o_B34_L12N_MRCC  , // # W4     # FPGA_M1_SPI_nCS5
	output wire  o_B34_L13P_MRCC  , // # R4     # FPGA_M1_SPI_nCS6
	output wire  o_B34_L13N_MRCC  , // # T4     # FPGA_M1_SPI_nCS7
	output wire  o_B34_L14P_SRCC  , // # T5     # FPGA_M1_SPI_nCS8
	output wire  o_B34_L14N_SRCC  , // # U5     # FPGA_M1_SPI_nCS9
	output wire  o_B34_L15P       , // # W6     # FPGA_M1_SPI_nCS10
	output wire  o_B34_L15N       , // # W5     # FPGA_M1_SPI_nCS11
	output wire  o_B34_L16P       , // # U6     # FPGA_M1_SPI_nCS12
											    
	output wire  o_B34_L16N       , // # V5     # M1_SPI_TX_CLK
	output wire  o_B34_L17P       , // # R6     # M1_SPI_MOSI
	input  wire  i_B34_L17N       , // # T6     # M1_SPI_RX_CLK
	input  wire  i_B34_L18P       , // # Y6     # M1_SPI_MISO
	
	//  # IO_B34_L18N             , // # AA6    # NA
											   
	output wire  o_B34_L19P       , // # V7     # TRIG
	output wire  o_B34_L19N       , // # W7     # SOT
	output wire  o_B34_L20P       , // # AB7    # PRE_TRIG
	
	//  # IO_B34_L20N             , // # AB6    # NA
	
	input  wire  i_B34_L21P       , // # V9     # FPGA_H_IN1
	input  wire  i_B34_L21N       , // # V8     # FPGA_H_IN2
	input  wire  i_B34_L22P       , // # AA8    # FPGA_H_IN3
	input  wire  i_B34_L22N       , // # AB8    # FPGA_H_IN4
											   
	output wire  o_B34_L23P       , // # Y8     # FPGA_H_OUT1
	output wire  o_B34_L23N       , // # Y7     # FPGA_H_OUT2
	output wire  o_B34_L24P       , // # W9     # FPGA_H_OUT3
	output wire  o_B34_L24N       , // # Y9     # FPGA_H_OUT4
											   
	output wire  o_B34_25         , // # U7     # FPGA_EXT_TRIG_OUT_D
	
	//}


	//// BANK B35 //{
	
	input  wire  i_B35_0_         , // # F4     # BUF_MASTER0
											   
	output wire  o_B35_L1P        , // # B1     # FPGA_M2_SPI_nCS0
	output wire  o_B35_L1N        , // # A1     # FPGA_M2_SPI_nCS1
	output wire  o_B35_L2P        , // # C2     # FPGA_M2_SPI_nCS2
	output wire  o_B35_L2N        , // # B2     # FPGA_M2_SPI_nCS3
	output wire  o_B35_L3P        , // # E1     # FPGA_M2_SPI_nCS4
	output wire  o_B35_L3N        , // # D1     # FPGA_M2_SPI_nCS5
	output wire  o_B35_L4P        , // # E2     # FPGA_M2_SPI_nCS6
	output wire  o_B35_L4N        , // # D2     # FPGA_M2_SPI_nCS7
	output wire  o_B35_L5P        , // # G1     # FPGA_M2_SPI_nCS8
	output wire  o_B35_L5N        , // # F1     # FPGA_M2_SPI_nCS9
	output wire  o_B35_L6P        , // # F3     # FPGA_M2_SPI_nCS10
	output wire  o_B35_L6N        , // # E3     # FPGA_M2_SPI_nCS11
	output wire  o_B35_L7P        , // # K1     # FPGA_M2_SPI_nCS12
											   
	output wire  o_B35_L7N        , // # J1     # M2_SPI_TX_CLK
	output wire  o_B35_L8P        , // # H2     # M2_SPI_MOSI
	input  wire  i_B35_L8N        , // # G2     # M2_SPI_RX_CLK
	input  wire  i_B35_L9P        , // # K2     # M2_SPI_MISO
											   
	// IO_B35_L9N        , // # J2    # NA     
											   
	output wire  o_B35_L10P       , // # J5     # FPGA_CAL_SPI_nCS0
	output wire  o_B35_L10N       , // # H5     # FPGA_CAL_SPI_nCS1
	output wire  o_B35_L11P_SRCC  , // # H3     # FPGA_CAL_SPI_nCS2
	output wire  o_B35_L11N_SRCC  , // # G3     # FPGA_CAL_SPI_nCS3
	output wire  o_B35_L12P_MRCC  , // # H4     # FPGA_CAL_SPI_nCS4
	output wire  o_B35_L12N_MRCC  , // # G4     # FPGA_CAL_SPI_nCS5
	output wire  o_B35_L13P_MRCC  , // # K4     # FPGA_CAL_SPI_nCS6
	output wire  o_B35_L13N_MRCC  , // # J4     # FPGA_CAL_SPI_nCS7
	output wire  o_B35_L14P_SRCC  , // # L3     # FPGA_CAL_SPI_nCS8
	output wire  o_B35_L14N_SRCC  , // # K3     # FPGA_CAL_SPI_nCS9
	output wire  o_B35_L15P       , // # M1     # FPGA_CAL_SPI_nCS10
	output wire  o_B35_L15N       , // # L1     # FPGA_CAL_SPI_nCS11
	output wire  o_B35_L16P       , // # M3     # FPGA_CAL_SPI_nCS12
											   
	output wire  o_B35_L16N       , // # M2     # FPGA_CAL_SPI_TX_CLK
	output wire  o_B35_L17P       , // # K6     # FPGA_CAL_SPI_MOSI
	input  wire  i_B35_L17N       , // # J6     # FPGA_CAL_SPI_MISO
	output wire  o_B35_L18P       , // # L5     # FPGA_nRESET_OUT
											   
	// IO_B35_L18N       , // # L4    # NA     
											   
	input  wire  i_B35_L19P       , // # N4     # BUF_LAN_IP0
	input  wire  i_B35_L19N       , // # N3     # BUF_LAN_IP1
	input  wire  i_B35_L20P       , // # R1     # BUF_LAN_IP2
	input  wire  i_B35_L20N       , // # P1     # BUF_LAN_IP3
											   
	output wire  o_B35_L21P       , // # P5     # FPGA_RESERVED0
	output wire  o_B35_L21N       , // # P4     # FPGA_RESERVED1
	output wire  o_B35_L22P       , // # P2     # FPGA_RESERVED2
											   
	output wire  o_B35_L22N       , // # N2     # EXT_TRIG_CW_IN
	output wire  o_B35_L23P       , // # M6     # EXT_TRIG_DIGITAL_IN
	output wire  o_B35_L23N       , // # M5     # EXT_TRIG_CW_OUT
	output wire  o_B35_L24P       , // # P6     # EXT_TRIG_DIGITAL_OUT
	output wire  o_B35_L24N       , // # N5     # EXT_TRIG_BYPASS
											   
	input  wire  i_B35_25         , // # L6     # BUF_MASTER1
	
	//}
	
	

	//// external clock ports on B13 //{
	input  wire  sys_clkp,  // # i_B13_L12P_MRCC  # W11 
	input  wire  sys_clkn,  // # i_B13_L12N_MRCC  # W12 
	//}

	//// XADC input on B0 //{
	input  wire  i_XADC_VP, // # L10   VP_0      CONFIG    
	input  wire  i_XADC_VN  // # M9    VN_0      CONFIG    
	//}
	
	);


/*parameter common */  //{
	
// TODO: FPGA_IMAGE_ID = h_BD_21_0310   //{
//parameter FPGA_IMAGE_ID = 32'h_A0_21_0407;   // S3100-CPU-BASE // pin map setup
//parameter FPGA_IMAGE_ID = 32'h_A0_21_0416; // S3100-CPU-BASE // pll, endpoints setup
//parameter FPGA_IMAGE_ID = 32'h_A0_21_0702; // S3100-CPU-BASE // MSPI-M0 - SSPI-M2 test
//parameter FPGA_IMAGE_ID = 32'h_A0_21_0706; // S3100-CPU-BASE // update M0 M1 M2 CS pin control
//parameter FPGA_IMAGE_ID = 32'h_A0_21_07A6; // S3100-CPU-BASE // update spi miso pin control
//parameter FPGA_IMAGE_ID = 32'h_A0_21_0707; // S3100-CPU-BASE // revise master spi timing
parameter FPGA_IMAGE_ID = 32'h_A0_21_0810; // S3100-CPU-BASE // merge git // review ARM interface


//}

//}


///TODO: //-------------------------------------------------------//


/* TODO: IO BUF assignment */ //{


//// BANK B14 IOBUF //{

wire FPGA_IO0;
wire FPGA_IO1;
wire FPGA_IO2;
wire FPGA_IO3;
wire FPGA_IO4;
wire FPGA_IO5;
OBUF obuf__FPGA_IO0__inst(.O( o_B14_L4P ), .I( FPGA_IO0 ) ); 
OBUF obuf__FPGA_IO1__inst(.O( o_B14_L4N ), .I( FPGA_IO1 ) ); 
OBUF obuf__FPGA_IO2__inst(.O( o_B14_L5P ), .I( FPGA_IO2 ) ); 
OBUF obuf__FPGA_IO3__inst(.O( o_B14_L5N ), .I( FPGA_IO3 ) ); 
OBUF obuf__FPGA_IO4__inst(.O( o_B14_L6N ), .I( FPGA_IO4 ) );
OBUF obuf__FPGA_IO5__inst(.O( o_B14_L7P ), .I( FPGA_IO5 ) );

wire FPGA_MBD_RS_422_SPI_EN  ;
wire FPGA_MBD_RS_422_TRIG_EN ;
wire FPGA_M0_SPI_TX_EN       ; //$$ to revise ... cowork with ARM core 
wire FPGA_M1_SPI_TX_EN       ; //$$ to revise ... cowork with ARM core 
wire FPGA_M2_SPI_TX_EN       ; //$$ to revise ... cowork with ARM core 
wire FPGA_TRIG_TX_EN         = 1'b0; // test
OBUF obuf__FPGA_MBD_RS_422_SPI_EN___inst(.O( o_B14_L7N  ), .I( FPGA_MBD_RS_422_SPI_EN  ) );
OBUF obuf__FPGA_MBD_RS_422_TRIG_EN__inst(.O( o_B14_L8P  ), .I( FPGA_MBD_RS_422_TRIG_EN ) );
OBUF obuf__FPGA_M0_SPI_TX_EN________inst(.O( o_B14_L8N  ), .I( FPGA_M0_SPI_TX_EN       ) );
OBUF obuf__FPGA_M1_SPI_TX_EN________inst(.O( o_B14_L9P  ), .I( FPGA_M1_SPI_TX_EN       ) );
OBUF obuf__FPGA_M2_SPI_TX_EN________inst(.O( o_B14_L9N  ), .I( FPGA_M2_SPI_TX_EN       ) );
OBUF obuf__FPGA_TRIG_TX_EN__________inst(.O( o_B14_L10P ), .I( FPGA_TRIG_TX_EN         ) );

// ## LED
//$$ S3100 vs TXEM7310
//// note: fpga module    in B16 uses high-Z output // 7..0 ... B17,B16,A16,B15,A15,A14,B13,A13
//// note: S3100-CPU-BASE in B14 uses high-Z output // 7..0 ... V19,V18,Y19,Y18,W20,W19,V20,U20
(* keep = "true" *) wire [7:0] led; //$$
wire FPGA_LED0_tri = led[0];  wire FPGA_LED0_out = 1'b0;  wire FPGA_LED0_in; // *_in unused
wire FPGA_LED1_tri = led[1];  wire FPGA_LED1_out = 1'b0;  wire FPGA_LED1_in; // *_in unused
wire FPGA_LED2_tri = led[2];  wire FPGA_LED2_out = 1'b0;  wire FPGA_LED2_in; // *_in unused
wire FPGA_LED3_tri = led[3];  wire FPGA_LED3_out = 1'b0;  wire FPGA_LED3_in; // *_in unused
wire FPGA_LED4_tri = led[4];  wire FPGA_LED4_out = 1'b0;  wire FPGA_LED4_in; // *_in unused
wire FPGA_LED5_tri = led[5];  wire FPGA_LED5_out = 1'b0;  wire FPGA_LED5_in; // *_in unused
wire FPGA_LED6_tri = led[6];  wire FPGA_LED6_out = 1'b0;  wire FPGA_LED6_in; // *_in unused
wire FPGA_LED7_tri = led[7];  wire FPGA_LED7_out = 1'b0;  wire FPGA_LED7_in; // *_in unused
//
IOBUF iobuf__FPGA_LED0__inst(.IO(io_B14_L11P_SRCC ), .T( FPGA_LED0_tri ) , .I( FPGA_LED0_out ), .O( FPGA_LED0_in  ) ); 
IOBUF iobuf__FPGA_LED1__inst(.IO(io_B14_L11N_SRCC ), .T( FPGA_LED1_tri ) , .I( FPGA_LED1_out ), .O( FPGA_LED1_in  ) ); 
IOBUF iobuf__FPGA_LED2__inst(.IO(io_B14_L12P_MRCC ), .T( FPGA_LED2_tri ) , .I( FPGA_LED2_out ), .O( FPGA_LED2_in  ) ); 
IOBUF iobuf__FPGA_LED3__inst(.IO(io_B14_L12N_MRCC ), .T( FPGA_LED3_tri ) , .I( FPGA_LED3_out ), .O( FPGA_LED3_in  ) ); 
IOBUF iobuf__FPGA_LED4__inst(.IO(io_B14_L13P_MRCC ), .T( FPGA_LED4_tri ) , .I( FPGA_LED4_out ), .O( FPGA_LED4_in  ) ); 
IOBUF iobuf__FPGA_LED5__inst(.IO(io_B14_L13N_MRCC ), .T( FPGA_LED5_tri ) , .I( FPGA_LED5_out ), .O( FPGA_LED5_in  ) ); 
IOBUF iobuf__FPGA_LED6__inst(.IO(io_B14_L14P_SRCC ), .T( FPGA_LED6_tri ) , .I( FPGA_LED6_out ), .O( FPGA_LED6_in  ) ); 
IOBUF iobuf__FPGA_LED7__inst(.IO(io_B14_L14N_SRCC ), .T( FPGA_LED7_tri ) , .I( FPGA_LED7_out ), .O( FPGA_LED7_in  ) ); 


wire FPGA_GPIO_PB5 = 1'b0; // test
wire FPGA_GPIO_PC4 = 1'b0; // test
wire FPGA_GPIO_PC5 = 1'b0; // test
wire FPGA_GPIO_PH4 = 1'b0; // test
wire FPGA_GPIO_PH6 = 1'b0; // test
wire FPGA_GPIO_PH7 ; // --> ETH_nIRQ
OBUF obuf__FPGA_GPIO_PB5__inst(.O( o_B14_L16N  ), .I( FPGA_GPIO_PB5 ) );
OBUF obuf__FPGA_GPIO_PC4__inst(.O( o_B14_L17P  ), .I( FPGA_GPIO_PC4 ) );
OBUF obuf__FPGA_GPIO_PC5__inst(.O( o_B14_L17N  ), .I( FPGA_GPIO_PC5 ) );
OBUF obuf__FPGA_GPIO_PH4__inst(.O( o_B14_L18P  ), .I( FPGA_GPIO_PH4 ) );
OBUF obuf__FPGA_GPIO_PH6__inst(.O( o_B14_L18N  ), .I( FPGA_GPIO_PH6 ) );
OBUF obuf__FPGA_GPIO_PH7__inst(.O( o_B14_L19P  ), .I( FPGA_GPIO_PH7 ) );
				 				 		 
wire FPGA_GPIO_PC9  = 1'b0; // test
wire FPGA_GPIO_PC10 = 1'b0; // test
wire FPGA_GPIO_PC11 = 1'b0; // test
wire FPGA_GPIO_PC12 = 1'b0; // test
wire FPGA_GPIO_PC13 = 1'b0; // test
wire FPGA_GPIO_PC14 = 1'b0; // test
wire FPGA_GPIO_PC15 = 1'b0; // test
OBUF obuf__FPGA_GPIO_PC9___inst(.O( o_B14_L19N  ), .I( FPGA_GPIO_PC9  ) );
OBUF obuf__FPGA_GPIO_PC10__inst(.O( o_B14_L20P  ), .I( FPGA_GPIO_PC10 ) );
OBUF obuf__FPGA_GPIO_PC11__inst(.O( o_B14_L20N  ), .I( FPGA_GPIO_PC11 ) );
OBUF obuf__FPGA_GPIO_PC12__inst(.O( o_B14_L21P  ), .I( FPGA_GPIO_PC12 ) );
OBUF obuf__FPGA_GPIO_PC13__inst(.O( o_B14_L21N  ), .I( FPGA_GPIO_PC13 ) );
OBUF obuf__FPGA_GPIO_PC14__inst(.O( o_B14_L22P  ), .I( FPGA_GPIO_PC14 ) );
OBUF obuf__FPGA_GPIO_PC15__inst(.O( o_B14_L22N  ), .I( FPGA_GPIO_PC15 ) );

wire FPGA_GPIO_PD2  ;
wire FPGA_GPIO_PI8  ;
wire FPGA_GPIO_PA8  ;
wire FPGA_GPIO_PB11 ;
IBUF ibuf__FPGA_GPIO_PD2__inst(.I( i_B14_L23P ), .O( FPGA_GPIO_PD2  ) ); //
IBUF ibuf__FPGA_GPIO_PI8__inst(.I( i_B14_L23N ), .O( FPGA_GPIO_PI8  ) ); //
IBUF ibuf__FPGA_GPIO_PA8__inst(.I( i_B14_L24P ), .O( FPGA_GPIO_PA8  ) ); //
IBUF ibuf__FPGA_GPIO_PB11_inst(.I( i_B14_L24N ), .O( FPGA_GPIO_PB11 ) ); //

	
//}

//// BANK B15 IOBUF //{

wire F_RDY       = 1'b0;
wire BUF_FMC_CLK ;
OBUF obuf__F_RDY__inst      ( .O( o_B15_0_ ), .I( F_RDY        ) );
IBUF ibuf__BUF_FMC_CLK__inst( .I( i_B15_25 ), .O( BUF_FMC_CLK  ) );

(* keep = "true" *) wire [7:0] test_point;               //$$
wire  F_TP0 = test_point[0] ;
wire  F_TP1 = test_point[1] ;
wire  F_TP2 = test_point[2] ;
wire  F_TP3 = test_point[3] ;
wire  F_TP4 = test_point[4] ;
wire  F_TP5 = test_point[5] ;
wire  F_TP6 = test_point[6] ;
wire  F_TP7 = test_point[7] ;

OBUF obuf__F_TP0__inst(.O( o_B15_L2N_AD8N ), .I( F_TP0 ) );
OBUF obuf__F_TP1__inst(.O( o_B15_L5P_AD9P ), .I( F_TP1 ) );
OBUF obuf__F_TP2__inst(.O( o_B15_L5N_AD9N ), .I( F_TP2 ) );
OBUF obuf__F_TP3__inst(.O( o_B15_L2P_AD8P ), .I( F_TP3 ) );

OBUF obuf__F_TP4__inst(.O( o_B15_L3P_AD1P ), .I( F_TP4 ) );
OBUF obuf__F_TP5__inst(.O( o_B15_L3N_AD1N ), .I( F_TP5 ) );
OBUF obuf__F_TP6__inst(.O( o_B15_L1P_AD0P ), .I( F_TP6 ) );
OBUF obuf__F_TP7__inst(.O( o_B15_L1N_AD0N ), .I( F_TP7 ) );

wire EXT_I2C_4_SCL_in  ;
wire EXT_I2C_4_SDA_tri = 1'b1; wire EXT_I2C_4_SDA_out = 1'b0; wire EXT_I2C_4_SDA_in  ;
IBUF   ibuf__EXT_I2C_4_SCL__inst( .I( i_B15_L4P ), .O( EXT_I2C_4_SCL_in  ) );
IOBUF iobuf__EXT_I2C_4_SDA__inst(.IO(io_B15_L4N ), 
								                   .T( EXT_I2C_4_SDA_tri ) , 
								                   .I( EXT_I2C_4_SDA_out ) , 
								                   .O( EXT_I2C_4_SDA_in  ) ); 
								   
// ## LAN 
wire  LAN_PWDN    = 1'b0; // unused 
wire  LAN_RST_B   ;
wire  LAN_SSAUX_B = 1'b1; // unused 
wire  LAN_SSN_B   ;
wire  LAN_MOSI    ;
wire  LAN_SCLK    ;
wire  LAN_INT_B   ;
wire  LAN_MISO    ;
OBUF obuf__LAN_PWDN_____inst(.O( o_B15_L6P ), .I( LAN_PWDN    ) );
OBUF obuf__LAN_RST_B____inst(.O( o_B15_L9P ), .I( LAN_RST_B   ) );
OBUF obuf__LAN_SSAUX_B__inst(.O( o_B15_L6N ), .I( LAN_SSAUX_B ) );
OBUF obuf__LAN_SSN_B____inst(.O( o_B15_L8P ), .I( LAN_SSN_B   ) );
OBUF obuf__LAN_MOSI_____inst(.O( o_B15_L7P ), .I( LAN_MOSI    ) );
OBUF obuf__LAN_SCLK_____inst(.O( o_B15_L7N ), .I( LAN_SCLK    ) );
IBUF ibuf__LAN_INT_B____inst( .I( i_B15_L8N ), .O( LAN_INT_B   ) );
IBUF ibuf__LAN_MISO_____inst( .I( i_B15_L9N ), .O( LAN_MISO    ) );
	
// # H20  # AUX_AD11P ## unused
// # G20  # AUX_AD11N ## unused

// ## EEPROM 
//$$ S3100 vs TXEM7310
//// note: fpga module in PGU    uses io_B34_L5N       // Y1
//// note: S3100-CPU-BASE SCIO_0 uses io_B15_L11P_SRCC // J20
wire SCIO_0_tri ; wire SCIO_0_out ; wire SCIO_0_in  ;
wire SCIO_1_tri ; wire SCIO_1_out ; wire SCIO_1_in  ;
IOBUF iobuf__SCIO_0__inst(.IO(io_B15_L11P_SRCC ), 
			                   .T( SCIO_0_tri ) , 
			                   .I( SCIO_0_out ) , 
			                   .O( SCIO_0_in  ) ); 
IOBUF iobuf__SCIO_1__inst(.IO(io_B15_L11N_SRCC ), 
			                   .T( SCIO_1_tri ) , 
			                   .I( SCIO_1_out ) , 
			                   .O( SCIO_1_in  ) ); 

(* keep = "true" *) wire  GPIB_nCS      ; //
(* keep = "true" *) wire  GPIB_nRESET   ;
(* keep = "true" *) wire  GPIB_SW_nOE   ; // = 1'b1; // test // not enabled
(* keep = "true" *) wire  GPIB_DATA_DIR ;
(* keep = "true" *) wire  GPIB_DATA_nOE ;
//
(* keep = "true" *) wire  GPIB_IRQ      ;
(* keep = "true" *) wire  GPIB_REM      ;
(* keep = "true" *) wire  GPIB_TADCS    ;
(* keep = "true" *) wire  GPIB_LADCS    ;
(* keep = "true" *) wire  GPIB_DCAS     ;
(* keep = "true" *) wire  GPIB_TRIG     ;
OBUF obuf__GPIB_nCS_______inst(.O( o_B15_L12N_MRCC ), .I( GPIB_nCS      ) );
OBUF obuf__GPIB_nRESET____inst(.O( o_B15_L13P_MRCC ), .I( GPIB_nRESET   ) );
OBUF obuf__GPIB_SW_nOE____inst(.O( o_B15_L13N_MRCC ), .I( GPIB_SW_nOE   ) );
OBUF obuf__GPIB_DATA_DIR__inst(.O( o_B15_L16N      ), .I( GPIB_DATA_DIR ) );
OBUF obuf__GPIB_DATA_nOE__inst(.O( o_B15_L17P      ), .I( GPIB_DATA_nOE ) );
IBUF ibuf__GPIB_IRQ_______inst( .I( i_B15_L12P_MRCC ), .O( GPIB_IRQ      ) );
IBUF ibuf__GPIB_REM_______inst( .I( i_B15_L14P_SRCC ), .O( GPIB_REM      ) );
IBUF ibuf__GPIB_TADCS_____inst( .I( i_B15_L14N_SRCC ), .O( GPIB_TADCS    ) );
IBUF ibuf__GPIB_LADCS_____inst( .I( i_B15_L15P      ), .O( GPIB_LADCS    ) );
IBUF ibuf__GPIB_DCAS______inst( .I( i_B15_L15N      ), .O( GPIB_DCAS     ) );
IBUF ibuf__GPIB_TRIG______inst( .I( i_B15_L16P      ), .O( GPIB_TRIG     ) );

// # N19  # NA
							        
wire  BA25 ;
wire  BA24 ;
wire  BA23 ;
wire  BA22 ;
wire  BA21 ;
wire  BA20 ;
wire  BA19 ;
wire  BA18 ;
wire  BA7  ;
wire  BA6  ;
wire  BA5  ;
wire  BA4  ;
wire  BA3  ;
wire  BA2  ;
IBUF ibuf__BA25__inst( .I( i_B15_L18P ), .O( BA25 ) );
IBUF ibuf__BA24__inst( .I( i_B15_L18N ), .O( BA24 ) );
IBUF ibuf__BA23__inst( .I( i_B15_L19P ), .O( BA23 ) );
IBUF ibuf__BA22__inst( .I( i_B15_L19N ), .O( BA22 ) );
IBUF ibuf__BA21__inst( .I( i_B15_L20P ), .O( BA21 ) );
IBUF ibuf__BA20__inst( .I( i_B15_L20N ), .O( BA20 ) );
IBUF ibuf__BA19__inst( .I( i_B15_L21P ), .O( BA19 ) );
IBUF ibuf__BA18__inst( .I( i_B15_L21N ), .O( BA18 ) );
IBUF ibuf__BA7___inst( .I( i_B15_L22P ), .O( BA7  ) );
IBUF ibuf__BA6___inst( .I( i_B15_L22N ), .O( BA6  ) );
IBUF ibuf__BA5___inst( .I( i_B15_L23P ), .O( BA5  ) );
IBUF ibuf__BA4___inst( .I( i_B15_L23N ), .O( BA4  ) );
IBUF ibuf__BA3___inst( .I( i_B15_L24P ), .O( BA3  ) );
IBUF ibuf__BA2___inst( .I( i_B15_L24N ), .O( BA2  ) );


//}

//// BANK B16 IOBUF //{

wire  BASE_F_LED_ERR ; //
wire  RUN_FPGA_LED   ; //
wire  BUF_nRESET     ;
OBUF obuf__BASE_F_LED_ERR__inst(.O( o_B16_0_   ), .I( BASE_F_LED_ERR ) );
OBUF obuf__RUN_FPGA_LED____inst(.O( o_B16_25   ), .I( RUN_FPGA_LED   ) );
IBUF ibuf__BUF_nRESET______inst( .I( i_B16_L24N ), .O( BUF_nRESET     ) );
	
// A logic High on the T pin disables the output buffer (T = '1' ==> 'Z' (INPUT)) 	
	
wire BD0__tri ;  wire BD0__out ;  wire BD0__in ;
wire BD1__tri ;  wire BD1__out ;  wire BD1__in ;
wire BD2__tri ;  wire BD2__out ;  wire BD2__in ;
wire BD3__tri ;  wire BD3__out ;  wire BD3__in ;
wire BD4__tri ;  wire BD4__out ;  wire BD4__in ;
wire BD5__tri ;  wire BD5__out ;  wire BD5__in ;
wire BD6__tri ;  wire BD6__out ;  wire BD6__in ;
wire BD7__tri ;  wire BD7__out ;  wire BD7__in ;
wire BD8__tri ;  wire BD8__out ;  wire BD8__in ;
wire BD9__tri ;  wire BD9__out ;  wire BD9__in ;
wire BD10_tri ;  wire BD10_out ;  wire BD10_in ;
wire BD11_tri ;  wire BD11_out ;  wire BD11_in ;
wire BD12_tri ;  wire BD12_out ;  wire BD12_in ;
wire BD13_tri ;  wire BD13_out ;  wire BD13_in ;
wire BD14_tri ;  wire BD14_out ;  wire BD14_in ;
wire BD15_tri ;  wire BD15_out ;  wire BD15_in ;
wire BD16_tri ;  wire BD16_out ;  wire BD16_in ;
wire BD17_tri ;  wire BD17_out ;  wire BD17_in ;
wire BD18_tri ;  wire BD18_out ;  wire BD18_in ;
wire BD19_tri ;  wire BD19_out ;  wire BD19_in ;
wire BD20_tri ;  wire BD20_out ;  wire BD20_in ;
wire BD21_tri ;  wire BD21_out ;  wire BD21_in ;
wire BD22_tri ;  wire BD22_out ;  wire BD22_in ;
wire BD23_tri ;  wire BD23_out ;  wire BD23_in ;
wire BD24_tri ;  wire BD24_out ;  wire BD24_in ;
wire BD25_tri ;  wire BD25_out ;  wire BD25_in ;
wire BD26_tri ;  wire BD26_out ;  wire BD26_in ;
wire BD27_tri ;  wire BD27_out ;  wire BD27_in ;
wire BD28_tri ;  wire BD28_out ;  wire BD28_in ;
wire BD29_tri ;  wire BD29_out ;  wire BD29_in ;
wire BD30_tri ;  wire BD30_out ;  wire BD30_in ;
wire BD31_tri ;  wire BD31_out ;  wire BD31_in ;
IOBUF iobuf__BD0___inst(.IO( io_B16_L1P  ), .T( BD0__tri ), .I( BD0__out ), .O( BD0__in  ) ); 
IOBUF iobuf__BD1___inst(.IO( io_B16_L1N  ), .T( BD1__tri ), .I( BD1__out ), .O( BD1__in  ) ); 
IOBUF iobuf__BD2___inst(.IO( io_B16_L2P  ), .T( BD2__tri ), .I( BD2__out ), .O( BD2__in  ) ); 
IOBUF iobuf__BD3___inst(.IO( io_B16_L2N  ), .T( BD3__tri ), .I( BD3__out ), .O( BD3__in  ) ); 
IOBUF iobuf__BD4___inst(.IO( io_B16_L3P  ), .T( BD4__tri ), .I( BD4__out ), .O( BD4__in  ) ); 
IOBUF iobuf__BD5___inst(.IO( io_B16_L3N  ), .T( BD5__tri ), .I( BD5__out ), .O( BD5__in  ) ); 
IOBUF iobuf__BD6___inst(.IO( io_B16_L4P  ), .T( BD6__tri ), .I( BD6__out ), .O( BD6__in  ) ); 
IOBUF iobuf__BD7___inst(.IO( io_B16_L4N  ), .T( BD7__tri ), .I( BD7__out ), .O( BD7__in  ) ); 
IOBUF iobuf__BD8___inst(.IO( io_B16_L5P  ), .T( BD8__tri ), .I( BD8__out ), .O( BD8__in  ) ); 
IOBUF iobuf__BD9___inst(.IO( io_B16_L5N  ), .T( BD9__tri ), .I( BD9__out ), .O( BD9__in  ) ); 
IOBUF iobuf__BD10__inst(.IO( io_B16_L6P  ), .T( BD10_tri ), .I( BD10_out ), .O( BD10_in  ) ); 
IOBUF iobuf__BD11__inst(.IO( io_B16_L6N  ), .T( BD11_tri ), .I( BD11_out ), .O( BD11_in  ) ); 
IOBUF iobuf__BD12__inst(.IO( io_B16_L7P  ), .T( BD12_tri ), .I( BD12_out ), .O( BD12_in  ) ); 
IOBUF iobuf__BD13__inst(.IO( io_B16_L7N  ), .T( BD13_tri ), .I( BD13_out ), .O( BD13_in  ) ); 
IOBUF iobuf__BD14__inst(.IO( io_B16_L8P  ), .T( BD14_tri ), .I( BD14_out ), .O( BD14_in  ) ); 
IOBUF iobuf__BD15__inst(.IO( io_B16_L8N  ), .T( BD15_tri ), .I( BD15_out ), .O( BD15_in  ) ); 
IOBUF iobuf__BD16__inst(.IO( io_B16_L9P  ), .T( BD16_tri ), .I( BD16_out ), .O( BD16_in  ) ); 
IOBUF iobuf__BD17__inst(.IO( io_B16_L9N  ), .T( BD17_tri ), .I( BD17_out ), .O( BD17_in  ) ); 
IOBUF iobuf__BD18__inst(.IO( io_B16_L10P ), .T( BD18_tri ), .I( BD18_out ), .O( BD18_in  ) ); 
IOBUF iobuf__BD19__inst(.IO( io_B16_L10N ), .T( BD19_tri ), .I( BD19_out ), .O( BD19_in  ) ); 
IOBUF iobuf__BD20__inst(.IO( io_B16_L11P ), .T( BD20_tri ), .I( BD20_out ), .O( BD20_in  ) ); 
IOBUF iobuf__BD21__inst(.IO( io_B16_L11N ), .T( BD21_tri ), .I( BD21_out ), .O( BD21_in  ) ); 
IOBUF iobuf__BD22__inst(.IO( io_B16_L12P ), .T( BD22_tri ), .I( BD22_out ), .O( BD22_in  ) ); 
IOBUF iobuf__BD23__inst(.IO( io_B16_L12N ), .T( BD23_tri ), .I( BD23_out ), .O( BD23_in  ) ); 
IOBUF iobuf__BD24__inst(.IO( io_B16_L13P ), .T( BD24_tri ), .I( BD24_out ), .O( BD24_in  ) ); 
IOBUF iobuf__BD25__inst(.IO( io_B16_L13N ), .T( BD25_tri ), .I( BD25_out ), .O( BD25_in  ) ); 
IOBUF iobuf__BD26__inst(.IO( io_B16_L14P ), .T( BD26_tri ), .I( BD26_out ), .O( BD26_in  ) ); 
IOBUF iobuf__BD27__inst(.IO( io_B16_L14N ), .T( BD27_tri ), .I( BD27_out ), .O( BD27_in  ) ); 
IOBUF iobuf__BD28__inst(.IO( io_B16_L15P ), .T( BD28_tri ), .I( BD28_out ), .O( BD28_in  ) ); 
IOBUF iobuf__BD29__inst(.IO( io_B16_L15N ), .T( BD29_tri ), .I( BD29_out ), .O( BD29_in  ) ); 
IOBUF iobuf__BD30__inst(.IO( io_B16_L16P ), .T( BD30_tri ), .I( BD30_out ), .O( BD30_in  ) ); 
IOBUF iobuf__BD31__inst(.IO( io_B16_L16N ), .T( BD31_tri ), .I( BD31_out ), .O( BD31_in  ) ); 

// # A18  # NA

(* keep = "true" *) wire  BUF_DATA_DIR ; // 
(* keep = "true" *) wire  nBUF_DATA_OE ;
OBUF obuf__BUF_DATA_DIR__inst(.O( o_B16_L17N ), .I( BUF_DATA_DIR ) );
OBUF obuf__nBUF_DATA_OE__inst(.O( o_B16_L18P ), .I( nBUF_DATA_OE ) );

// # F20  # NA

(* keep = "true" *) wire  INTER_RELAY_O ; //
(* keep = "true" *) wire  INTER_LED_O   ; //
(* keep = "true" *) wire  INTER_LOCK_ON ;
OBUF obuf__INTER_RELAY_O__inst(.O( o_B16_L19P ), .I( INTER_RELAY_O ) );
OBUF obuf__INTER_LED_O____inst(.O( o_B16_L19N ), .I( INTER_LED_O   ) );
IBUF ibuf__INTER_LOCK_ON__inst( .I( i_B16_L20P ), .O( INTER_LOCK_ON ) );

// # B22  # NA

wire  nBNE1 ;
wire  nBNE2 ;
wire  nBNE3 ;
wire  nBNE4 ;
wire  nBOE  ;
wire  nBWE  ;
IBUF ibuf__nBNE1__inst( .I( i_B16_L21P ), .O( nBNE1 ) );
IBUF ibuf__nBNE2__inst( .I( i_B16_L21N ), .O( nBNE2 ) );
IBUF ibuf__nBNE3__inst( .I( i_B16_L22P ), .O( nBNE3 ) );
IBUF ibuf__nBNE4__inst( .I( i_B16_L22N ), .O( nBNE4 ) );
IBUF ibuf__nBOE___inst( .I( i_B16_L23P ), .O( nBOE  ) );
IBUF ibuf__nBWE___inst( .I( i_B16_L23N ), .O( nBWE  ) );
	
// # G21  # NA
	

//}

//// BANK B13 IOBUF //{

// # Y17  # NA
											  
wire  SPI__1_SCLK ;
wire  SPI__1_nCS  ;
wire  SPI__1_MOSI ;
wire  SPI__1_MISO = 1'b0; // test
IBUF ibuf__SPI__1_SCLK__inst( .I( i_B13_L1P ), .O( SPI__1_SCLK ) );
IBUF ibuf__SPI__1_nCS___inst( .I( i_B13_L1N ), .O( SPI__1_nCS  ) );
IBUF ibuf__SPI__1_MOSI__inst( .I( i_B13_L2P ), .O( SPI__1_MOSI ) );
OBUF obuf__SPI__1_MISO__inst( .O( o_B13_L2N ), .I( SPI__1_MISO ) );

wire  SPI__2_SCLK ;
wire  SPI__2_nCS  ;
wire  SPI__2_MOSI ;
wire  SPI__2_MISO = 1'b0; // test
IBUF ibuf__SPI__2_SCLK__inst( .I( i_B13_L3P ), .O( SPI__2_SCLK ) );
IBUF ibuf__SPI__2_nCS___inst( .I( i_B13_L3N ), .O( SPI__2_nCS  ) );
IBUF ibuf__SPI__2_MOSI__inst( .I( i_B13_L4P ), .O( SPI__2_MOSI ) );
OBUF obuf__SPI__2_MISO__inst( .O( o_B13_L4N ), .I( SPI__2_MISO ) );

wire  QSPI_BK1_NCS ;
wire  QSPI_CLK     ;
wire  QSPI_BK1_IO0_tri = 1'b1 ; wire  QSPI_BK1_IO0_out = 1'b0 ; wire  QSPI_BK1_IO0_in ;
wire  QSPI_BK1_IO1_tri = 1'b1 ; wire  QSPI_BK1_IO1_out = 1'b0 ; wire  QSPI_BK1_IO1_in ;
wire  QSPI_BK1_IO2_tri = 1'b1 ; wire  QSPI_BK1_IO2_out = 1'b0 ; wire  QSPI_BK1_IO2_in ;
wire  QSPI_BK1_IO3_tri = 1'b1 ; wire  QSPI_BK1_IO3_out = 1'b0 ; wire  QSPI_BK1_IO3_in ;
IBUF ibuf__QSPI_BK1_NCS__inst( .I( i_B13_L5P ), .O( QSPI_BK1_NCS ) );
IBUF ibuf__QSPI_CLK______inst( .I( i_B13_L5N ), .O( QSPI_CLK     ) );
IOBUF iobuf__QSPI_BK1_IO0__inst(.IO( io_B13_L6P  ), .T( QSPI_BK1_IO0_tri ), .I( QSPI_BK1_IO0_out ), .O( QSPI_BK1_IO0_in  ) ); 
IOBUF iobuf__QSPI_BK1_IO1__inst(.IO( io_B13_L6N  ), .T( QSPI_BK1_IO1_tri ), .I( QSPI_BK1_IO1_out ), .O( QSPI_BK1_IO1_in  ) ); 
IOBUF iobuf__QSPI_BK1_IO2__inst(.IO( io_B13_L7P  ), .T( QSPI_BK1_IO2_tri ), .I( QSPI_BK1_IO2_out ), .O( QSPI_BK1_IO2_in  ) ); 
IOBUF iobuf__QSPI_BK1_IO3__inst(.IO( io_B13_L7N  ), .T( QSPI_BK1_IO3_tri ), .I( QSPI_BK1_IO3_out ), .O( QSPI_BK1_IO3_in  ) ); 

// # AA9    # NA

(* keep = "true" *) wire  ETH_nRESET   ; //
(* keep = "true" *) wire  ETH_nCS      ; //
(* keep = "true" *) wire  ETH_nIRQ     ;
(* keep = "true" *) wire  ETH_nLINKLED ;
(* keep = "true" *) wire  ETH_nTXLED   ;
(* keep = "true" *) wire  ETH_nRXLED   ;
OBUF obuf__ETH_nRESET____inst( .O( o_B13_L9P       ), .I( ETH_nRESET   ) );
OBUF obuf__ETH_nCS_______inst( .O( o_B13_L9N       ), .I( ETH_nCS      ) );
IBUF ibuf__ETH_nIRQ______inst( .I( i_B13_L8N       ), .O( ETH_nIRQ     ) );
IBUF ibuf__ETH_nLINKLED__inst( .I( i_B13_L10P      ), .O( ETH_nLINKLED ) );
IBUF ibuf__ETH_nTXLED____inst( .I( i_B13_L10N      ), .O( ETH_nTXLED   ) );
IBUF ibuf__ETH_nRXLED____inst( .I( i_B13_L11P_SRCC ), .O( ETH_nRXLED   ) );

// # Y12    # NA

// # W11    # clocks sys_clkp (*)
// # W12    # clocks sys_clkn (*)

wire  SYNC_10MHz     ;
wire  EXT_TRIG_IN_CW ;
IBUF ibuf__SYNC_10MHz______inst( .I( i_B13_L13P_MRCC ), .O( SYNC_10MHz ) );
IBUF ibuf__EXT_TRIG_IN_CW__inst( .I( i_B13_L13N_MRCC ), .O( EXT_TRIG_IN_CW ) );

(* keep = "true" *) wire  FPGA_FAN_SENS_0 ;
(* keep = "true" *) wire  FPGA_FAN_SENS_1 ;
(* keep = "true" *) wire  FPGA_FAN_SENS_2 ;
(* keep = "true" *) wire  FPGA_FAN_SENS_3 ;
(* keep = "true" *) wire  FPGA_FAN_SENS_4 ;
(* keep = "true" *) wire  FPGA_FAN_SENS_5 ;
(* keep = "true" *) wire  FPGA_FAN_SENS_6 ;
(* keep = "true" *) wire  FPGA_FAN_SENS_7 ;
IBUF ibuf__FPGA_FAN_SENS_0__inst( .I( i_B13_L14P_SRCC ), .O( FPGA_FAN_SENS_0 ) );
IBUF ibuf__FPGA_FAN_SENS_1__inst( .I( i_B13_L14N_SRCC ), .O( FPGA_FAN_SENS_1 ) );
IBUF ibuf__FPGA_FAN_SENS_2__inst( .I( i_B13_L15P      ), .O( FPGA_FAN_SENS_2 ) );
IBUF ibuf__FPGA_FAN_SENS_3__inst( .I( i_B13_L15N      ), .O( FPGA_FAN_SENS_3 ) );
IBUF ibuf__FPGA_FAN_SENS_4__inst( .I( i_B13_L16P      ), .O( FPGA_FAN_SENS_4 ) );
IBUF ibuf__FPGA_FAN_SENS_5__inst( .I( i_B13_L16N      ), .O( FPGA_FAN_SENS_5 ) );
IBUF ibuf__FPGA_FAN_SENS_6__inst( .I( i_B13_L17P      ), .O( FPGA_FAN_SENS_6 ) );
IBUF ibuf__FPGA_FAN_SENS_7__inst( .I( i_B13_L17N      ), .O( FPGA_FAN_SENS_7 ) );

//}

//// BANK B34 IOBUF //{

wire  FPGA_EXT_TRIG_IN_D  ;
wire  FPGA_EXT_TRIG_OUT_D = 1'b0; // test
IBUF ibuf__FPGA_EXT_TRIG_IN_D___inst(.I( i_B34_0_ ), .O( FPGA_EXT_TRIG_IN_D  ) );
OBUF obuf__FPGA_EXT_TRIG_OUT_D__inst(.O( o_B34_25 ), .I( FPGA_EXT_TRIG_OUT_D ) );
											    
wire  FPGA_M0_SPI_nCS0_; //
wire  FPGA_M0_SPI_nCS1_; //
wire  FPGA_M0_SPI_nCS2_; //
wire  FPGA_M0_SPI_nCS3_; //
wire  FPGA_M0_SPI_nCS4_; //
wire  FPGA_M0_SPI_nCS5_; //
wire  FPGA_M0_SPI_nCS6_; //
wire  FPGA_M0_SPI_nCS7_; //
wire  FPGA_M0_SPI_nCS8_; //
wire  FPGA_M0_SPI_nCS9_; //
wire  FPGA_M0_SPI_nCS10; //
wire  FPGA_M0_SPI_nCS11; //
wire  FPGA_M0_SPI_nCS12; //
OBUF obuf__FPGA_M0_SPI_nCS0___inst(.O( o_B34_L1P ), .I( FPGA_M0_SPI_nCS0_ ) );
OBUF obuf__FPGA_M0_SPI_nCS1___inst(.O( o_B34_L1N ), .I( FPGA_M0_SPI_nCS1_ ) );
OBUF obuf__FPGA_M0_SPI_nCS2___inst(.O( o_B34_L2P ), .I( FPGA_M0_SPI_nCS2_ ) );
OBUF obuf__FPGA_M0_SPI_nCS3___inst(.O( o_B34_L2N ), .I( FPGA_M0_SPI_nCS3_ ) );
OBUF obuf__FPGA_M0_SPI_nCS4___inst(.O( o_B34_L3P ), .I( FPGA_M0_SPI_nCS4_ ) );
OBUF obuf__FPGA_M0_SPI_nCS5___inst(.O( o_B34_L3N ), .I( FPGA_M0_SPI_nCS5_ ) );
OBUF obuf__FPGA_M0_SPI_nCS6___inst(.O( o_B34_L4P ), .I( FPGA_M0_SPI_nCS6_ ) );
OBUF obuf__FPGA_M0_SPI_nCS7___inst(.O( o_B34_L4N ), .I( FPGA_M0_SPI_nCS7_ ) );
OBUF obuf__FPGA_M0_SPI_nCS8___inst(.O( o_B34_L5P ), .I( FPGA_M0_SPI_nCS8_ ) );
OBUF obuf__FPGA_M0_SPI_nCS9___inst(.O( o_B34_L5N ), .I( FPGA_M0_SPI_nCS9_ ) );
OBUF obuf__FPGA_M0_SPI_nCS10__inst(.O( o_B34_L6P ), .I( FPGA_M0_SPI_nCS10 ) );
OBUF obuf__FPGA_M0_SPI_nCS11__inst(.O( o_B34_L6N ), .I( FPGA_M0_SPI_nCS11 ) );
OBUF obuf__FPGA_M0_SPI_nCS12__inst(.O( o_B34_L7P ), .I( FPGA_M0_SPI_nCS12 ) );
											    
wire  M0_SPI_TX_CLK ;
wire  M0_SPI_MOSI   ;
wire  M0_SPI_RX_CLK ;
wire  M0_SPI_MISO   ;
OBUF obuf__M0_SPI_TX_CLK__inst(.O( o_B34_L7N ), .I( M0_SPI_TX_CLK ) );
OBUF obuf__M0_SPI_MOSI____inst(.O( o_B34_L8P ), .I( M0_SPI_MOSI   ) );
IBUF ibuf__M0_SPI_RX_CLK__inst(.I( i_B34_L8N ), .O( M0_SPI_RX_CLK ) );
IBUF ibuf__M0_SPI_MISO____inst(.I( i_B34_L9P ), .O( M0_SPI_MISO   ) );
	
// # AA3    # NA
	
wire  FPGA_M1_SPI_nCS0_ ; //
wire  FPGA_M1_SPI_nCS1_ ; //
wire  FPGA_M1_SPI_nCS2_ ; //
wire  FPGA_M1_SPI_nCS3_ ; //
wire  FPGA_M1_SPI_nCS4_ ; //
wire  FPGA_M1_SPI_nCS5_ ; //
wire  FPGA_M1_SPI_nCS6_ ; //
wire  FPGA_M1_SPI_nCS7_ ; //
wire  FPGA_M1_SPI_nCS8_ ; //
wire  FPGA_M1_SPI_nCS9_ ; //
wire  FPGA_M1_SPI_nCS10 ; //
wire  FPGA_M1_SPI_nCS11 ; //
wire  FPGA_M1_SPI_nCS12 ; //
OBUF obuf__FPGA_M1_SPI_nCS0___inst(.O( o_B34_L10P      ), .I( FPGA_M1_SPI_nCS0_ ) );
OBUF obuf__FPGA_M1_SPI_nCS1___inst(.O( o_B34_L10N      ), .I( FPGA_M1_SPI_nCS1_ ) );
OBUF obuf__FPGA_M1_SPI_nCS2___inst(.O( o_B34_L11P_SRCC ), .I( FPGA_M1_SPI_nCS2_ ) );
OBUF obuf__FPGA_M1_SPI_nCS3___inst(.O( o_B34_L11N_SRCC ), .I( FPGA_M1_SPI_nCS3_ ) );
OBUF obuf__FPGA_M1_SPI_nCS4___inst(.O( o_B34_L12P_MRCC ), .I( FPGA_M1_SPI_nCS4_ ) );
OBUF obuf__FPGA_M1_SPI_nCS5___inst(.O( o_B34_L12N_MRCC ), .I( FPGA_M1_SPI_nCS5_ ) );
OBUF obuf__FPGA_M1_SPI_nCS6___inst(.O( o_B34_L13P_MRCC ), .I( FPGA_M1_SPI_nCS6_ ) );
OBUF obuf__FPGA_M1_SPI_nCS7___inst(.O( o_B34_L13N_MRCC ), .I( FPGA_M1_SPI_nCS7_ ) );
OBUF obuf__FPGA_M1_SPI_nCS8___inst(.O( o_B34_L14P_SRCC ), .I( FPGA_M1_SPI_nCS8_ ) );
OBUF obuf__FPGA_M1_SPI_nCS9___inst(.O( o_B34_L14N_SRCC ), .I( FPGA_M1_SPI_nCS9_ ) );
OBUF obuf__FPGA_M1_SPI_nCS10__inst(.O( o_B34_L15P      ), .I( FPGA_M1_SPI_nCS10 ) );
OBUF obuf__FPGA_M1_SPI_nCS11__inst(.O( o_B34_L15N      ), .I( FPGA_M1_SPI_nCS11 ) );
OBUF obuf__FPGA_M1_SPI_nCS12__inst(.O( o_B34_L16P      ), .I( FPGA_M1_SPI_nCS12 ) );
									     		    
wire  M1_SPI_TX_CLK ;
wire  M1_SPI_MOSI   ;
wire  M1_SPI_RX_CLK ;
wire  M1_SPI_MISO   ;
OBUF obuf__M1_SPI_TX_CLK__inst(.O( o_B34_L16N ), .I( M1_SPI_TX_CLK ) );
OBUF obuf__M1_SPI_MOSI____inst(.O( o_B34_L17P ), .I( M1_SPI_MOSI   ) );
IBUF ibuf__M1_SPI_RX_CLK__inst(.I( i_B34_L17N ), .O( M1_SPI_RX_CLK ) );
IBUF ibuf__M1_SPI_MISO____inst(.I( i_B34_L18P ), .O( M1_SPI_MISO   ) );
	
// # AA6    # NA
											   
(* keep = "true" *) wire  TRIG     ;
(* keep = "true" *) wire  SOT      ;
(* keep = "true" *) wire  PRE_TRIG ;
OBUF obuf__TRIG______inst(.O( o_B34_L19P ), .I( TRIG     ) );
OBUF obuf__SOT_______inst(.O( o_B34_L19N ), .I( SOT      ) );
OBUF obuf__PRE_TRIG__inst(.O( o_B34_L20P ), .I( PRE_TRIG ) );
	
// # AB6    # NA
	
(* keep = "true" *) wire  FPGA_H_IN1 ;
(* keep = "true" *) wire  FPGA_H_IN2 ;
(* keep = "true" *) wire  FPGA_H_IN3 ;
(* keep = "true" *) wire  FPGA_H_IN4 ;
IBUF ibuf__FPGA_H_IN1__inst( .I( i_B34_L21P ), .O( FPGA_H_IN1 ) );
IBUF ibuf__FPGA_H_IN2__inst( .I( i_B34_L21N ), .O( FPGA_H_IN2 ) );
IBUF ibuf__FPGA_H_IN3__inst( .I( i_B34_L22P ), .O( FPGA_H_IN3 ) );
IBUF ibuf__FPGA_H_IN4__inst( .I( i_B34_L22N ), .O( FPGA_H_IN4 ) );
											   
(* keep = "true" *) wire  FPGA_H_OUT1 ;
(* keep = "true" *) wire  FPGA_H_OUT2 ;
(* keep = "true" *) wire  FPGA_H_OUT3 ;
(* keep = "true" *) wire  FPGA_H_OUT4 ;
OBUF obuf__FPGA_H_OUT1__inst(.O( o_B34_L23P ), .I( FPGA_H_OUT1 ) );
OBUF obuf__FPGA_H_OUT2__inst(.O( o_B34_L23N ), .I( FPGA_H_OUT2 ) );
OBUF obuf__FPGA_H_OUT3__inst(.O( o_B34_L24P ), .I( FPGA_H_OUT3 ) );
OBUF obuf__FPGA_H_OUT4__inst(.O( o_B34_L24N ), .I( FPGA_H_OUT4 ) );
											   


//}

//// BANK B35 IOBUF //{

(* keep = "true" *) wire  BUF_MASTER0 ;
(* keep = "true" *) wire  BUF_MASTER1 ;
IBUF ibuf__BUF_MASTER0__inst(.I( i_B35_0_ ), .O( BUF_MASTER0 ) );
IBUF ibuf__BUF_MASTER1__inst(.I( i_B35_25 ), .O( BUF_MASTER1 ) );
											   
wire  FPGA_M2_SPI_nCS0_ ; //
wire  FPGA_M2_SPI_nCS1_ ; //
wire  FPGA_M2_SPI_nCS2_ ; //
wire  FPGA_M2_SPI_nCS3_ ; //
wire  FPGA_M2_SPI_nCS4_ ; //
wire  FPGA_M2_SPI_nCS5_ ; //
wire  FPGA_M2_SPI_nCS6_ ; //
wire  FPGA_M2_SPI_nCS7_ ; //
wire  FPGA_M2_SPI_nCS8_ ; //
wire  FPGA_M2_SPI_nCS9_ ; //
wire  FPGA_M2_SPI_nCS10 ; //
wire  FPGA_M2_SPI_nCS11 ; //
wire  FPGA_M2_SPI_nCS12 ; //
OBUF obuf__FPGA_M2_SPI_nCS0___inst(.O( o_B35_L1P ), .I( FPGA_M2_SPI_nCS0_ ) );
OBUF obuf__FPGA_M2_SPI_nCS1___inst(.O( o_B35_L1N ), .I( FPGA_M2_SPI_nCS1_ ) );
OBUF obuf__FPGA_M2_SPI_nCS2___inst(.O( o_B35_L2P ), .I( FPGA_M2_SPI_nCS2_ ) );
OBUF obuf__FPGA_M2_SPI_nCS3___inst(.O( o_B35_L2N ), .I( FPGA_M2_SPI_nCS3_ ) );
OBUF obuf__FPGA_M2_SPI_nCS4___inst(.O( o_B35_L3P ), .I( FPGA_M2_SPI_nCS4_ ) );
OBUF obuf__FPGA_M2_SPI_nCS5___inst(.O( o_B35_L3N ), .I( FPGA_M2_SPI_nCS5_ ) );
OBUF obuf__FPGA_M2_SPI_nCS6___inst(.O( o_B35_L4P ), .I( FPGA_M2_SPI_nCS6_ ) );
OBUF obuf__FPGA_M2_SPI_nCS7___inst(.O( o_B35_L4N ), .I( FPGA_M2_SPI_nCS7_ ) );
OBUF obuf__FPGA_M2_SPI_nCS8___inst(.O( o_B35_L5P ), .I( FPGA_M2_SPI_nCS8_ ) );
OBUF obuf__FPGA_M2_SPI_nCS9___inst(.O( o_B35_L5N ), .I( FPGA_M2_SPI_nCS9_ ) );
OBUF obuf__FPGA_M2_SPI_nCS10__inst(.O( o_B35_L6P ), .I( FPGA_M2_SPI_nCS10 ) );
OBUF obuf__FPGA_M2_SPI_nCS11__inst(.O( o_B35_L6N ), .I( FPGA_M2_SPI_nCS11 ) );
OBUF obuf__FPGA_M2_SPI_nCS12__inst(.O( o_B35_L7P ), .I( FPGA_M2_SPI_nCS12 ) );
											   
wire  M2_SPI_TX_CLK ;
wire  M2_SPI_MOSI   ;
wire  M2_SPI_RX_CLK ;
wire  M2_SPI_MISO   ;
OBUF obuf__M2_SPI_TX_CLK__inst(.O( o_B35_L7N ), .I( M2_SPI_TX_CLK ) );
OBUF obuf__M2_SPI_MOSI____inst(.O( o_B35_L8P ), .I( M2_SPI_MOSI   ) );
IBUF ibuf__M2_SPI_RX_CLK__inst(.I( i_B35_L8N ), .O( M2_SPI_RX_CLK ) );
IBUF ibuf__M2_SPI_MISO____inst(.I( i_B35_L9P ), .O( M2_SPI_MISO   ) );
											   
// # J2    # NA     
											   
wire  FPGA_CAL_SPI_nCS0_ = 1'b1; // test
wire  FPGA_CAL_SPI_nCS1_ = 1'b1; // test
wire  FPGA_CAL_SPI_nCS2_ = 1'b1; // test
wire  FPGA_CAL_SPI_nCS3_ = 1'b1; // test
wire  FPGA_CAL_SPI_nCS4_ = 1'b1; // test
wire  FPGA_CAL_SPI_nCS5_ = 1'b1; // test
wire  FPGA_CAL_SPI_nCS6_ = 1'b1; // test
wire  FPGA_CAL_SPI_nCS7_ = 1'b1; // test
wire  FPGA_CAL_SPI_nCS8_ = 1'b1; // test
wire  FPGA_CAL_SPI_nCS9_ = 1'b1; // test
wire  FPGA_CAL_SPI_nCS10 = 1'b1; // test
wire  FPGA_CAL_SPI_nCS11 = 1'b1; // test
wire  FPGA_CAL_SPI_nCS12 = 1'b1; // test
OBUF obuf__FPGA_CAL_SPI_nCS0___inst(.O( o_B35_L10P      ), .I( FPGA_CAL_SPI_nCS0_ ) );
OBUF obuf__FPGA_CAL_SPI_nCS1___inst(.O( o_B35_L10N      ), .I( FPGA_CAL_SPI_nCS1_ ) );
OBUF obuf__FPGA_CAL_SPI_nCS2___inst(.O( o_B35_L11P_SRCC ), .I( FPGA_CAL_SPI_nCS2_ ) );
OBUF obuf__FPGA_CAL_SPI_nCS3___inst(.O( o_B35_L11N_SRCC ), .I( FPGA_CAL_SPI_nCS3_ ) );
OBUF obuf__FPGA_CAL_SPI_nCS4___inst(.O( o_B35_L12P_MRCC ), .I( FPGA_CAL_SPI_nCS4_ ) );
OBUF obuf__FPGA_CAL_SPI_nCS5___inst(.O( o_B35_L12N_MRCC ), .I( FPGA_CAL_SPI_nCS5_ ) );
OBUF obuf__FPGA_CAL_SPI_nCS6___inst(.O( o_B35_L13P_MRCC ), .I( FPGA_CAL_SPI_nCS6_ ) );
OBUF obuf__FPGA_CAL_SPI_nCS7___inst(.O( o_B35_L13N_MRCC ), .I( FPGA_CAL_SPI_nCS7_ ) );
OBUF obuf__FPGA_CAL_SPI_nCS8___inst(.O( o_B35_L14P_SRCC ), .I( FPGA_CAL_SPI_nCS8_ ) );
OBUF obuf__FPGA_CAL_SPI_nCS9___inst(.O( o_B35_L14N_SRCC ), .I( FPGA_CAL_SPI_nCS9_ ) );
OBUF obuf__FPGA_CAL_SPI_nCS10__inst(.O( o_B35_L15P      ), .I( FPGA_CAL_SPI_nCS10 ) );
OBUF obuf__FPGA_CAL_SPI_nCS11__inst(.O( o_B35_L15N      ), .I( FPGA_CAL_SPI_nCS11 ) );
OBUF obuf__FPGA_CAL_SPI_nCS12__inst(.O( o_B35_L16P      ), .I( FPGA_CAL_SPI_nCS12 ) );
											   
wire  FPGA_CAL_SPI_TX_CLK = 1'b0; // test
wire  FPGA_CAL_SPI_MOSI   = 1'b0; // test
wire  FPGA_CAL_SPI_MISO   ;
OBUF obuf__FPGA_CAL_SPI_TX_CLK__inst(.O( o_B35_L16N ), .I( FPGA_CAL_SPI_TX_CLK ) );
OBUF obuf__FPGA_CAL_SPI_MOSI____inst(.O( o_B35_L17P ), .I( FPGA_CAL_SPI_MOSI   ) );
IBUF ibuf__FPGA_CAL_SPI_MISO____inst(.I( i_B35_L17N ), .O( FPGA_CAL_SPI_MISO   ) );

wire FPGA_nRESET_OUT = 1'b1; // test
OBUF obuf__FPGA_nRESET_OUT__inst(.O( o_B35_L18P ), .I( FPGA_nRESET_OUT ) );
											   
// # L4    # NA     
											   
(* keep = "true" *) wire  BUF_LAN_IP0 ;
(* keep = "true" *) wire  BUF_LAN_IP1 ;
(* keep = "true" *) wire  BUF_LAN_IP2 ;
(* keep = "true" *) wire  BUF_LAN_IP3 ;
IBUF ibuf__BUF_LAN_IP0__inst(.I( i_B35_L19P ), .O( BUF_LAN_IP0  ) );
IBUF ibuf__BUF_LAN_IP1__inst(.I( i_B35_L19N ), .O( BUF_LAN_IP1  ) );
IBUF ibuf__BUF_LAN_IP2__inst(.I( i_B35_L20P ), .O( BUF_LAN_IP2  ) );
IBUF ibuf__BUF_LAN_IP3__inst(.I( i_B35_L20N ), .O( BUF_LAN_IP3  ) );
											   
wire  FPGA_RESERVED0 = 1'b0;// test
wire  FPGA_RESERVED1 = 1'b0;// test
wire  FPGA_RESERVED2 = 1'b0;// test
OBUF obuf__FPGA_RESERVED0__inst(.O( o_B35_L21P ), .I( FPGA_RESERVED0 ) );
OBUF obuf__FPGA_RESERVED1__inst(.O( o_B35_L21N ), .I( FPGA_RESERVED1 ) );
OBUF obuf__FPGA_RESERVED2__inst(.O( o_B35_L22P ), .I( FPGA_RESERVED2 ) );
											   
wire  EXT_TRIG_CW_IN       = 1'b0;// test
wire  EXT_TRIG_DIGITAL_IN  = 1'b0;// test
wire  EXT_TRIG_CW_OUT      = 1'b0;// test
wire  EXT_TRIG_DIGITAL_OUT = 1'b0;// test
wire  EXT_TRIG_BYPASS      = 1'b0;// test
OBUF obuf__EXT_TRIG_CW_IN________inst(.O( o_B35_L22N ), .I( EXT_TRIG_CW_IN       ) );
OBUF obuf__EXT_TRIG_DIGITAL_IN___inst(.O( o_B35_L23P ), .I( EXT_TRIG_DIGITAL_IN  ) );
OBUF obuf__EXT_TRIG_CW_OUT_______inst(.O( o_B35_L23N ), .I( EXT_TRIG_CW_OUT      ) );
OBUF obuf__EXT_TRIG_DIGITAL_OUT__inst(.O( o_B35_L24P ), .I( EXT_TRIG_DIGITAL_OUT ) );
OBUF obuf__EXT_TRIG_BYPASS_______inst(.O( o_B35_L24N ), .I( EXT_TRIG_BYPASS      ) );
											   

//}


//}


///TODO: //-------------------------------------------------------//


/* TODO: clock/pll and reset */ //{

// clock pll0 //{
wire clk_out1_200M ; // REFCLK 200MHz for IDELAYCTRL // for pll1
wire clk_out2_140M ; // for pll2 ... 140M
wire clk_out3_10M  ; // for slow logic / I2C //
wire clk_out4_10M ; // for XADC 
//
wire clk_locked_pre;
clk_wiz_0  clk_wiz_0_inst(
	// MMCM
	// VCO 700MHz
	// Clock out ports  
	.clk_out1_200M (clk_out1_200M ), // BUFG
	.clk_out2_140M (clk_out2_140M ), // BUFG
	// Status and control signals               
	.locked(clk_locked_pre),
	// Clock in ports
	.clk_in1_p(sys_clkp), // diff clock pin
	.clk_in1_n(sys_clkn)
);
////
clk_wiz_0_0_1  clk_wiz_0_0_1_inst(
	// Clock out ports  
	.clk_out1_10M (clk_out3_10M), // BUFGCE // due to soft-startup
	.clk_out2_10M (clk_out4_10M), // BUFGCE // due to soft-startup
	// Status and control signals     
	.resetn(clk_locked_pre),          
	.locked(), // not used
	// Clock in ports
	.clk_in1_200M(clk_out1_200M) // no buf
);

//}

// clock pll1 //{

wire clk1_locked = 1'b1; // unused // to remove

//}

// clock pll2 //{


wire clk2_locked = 1'b1; // unused // to remove



//}

// clock pll3 //{
wire clk3_out1_72M ; // MCS core; IO bridge
wire clk3_out2_144M; // LAN-SPI control 144MHz 
wire clk3_out3_12M ; // slow logic // not used yet
wire clk3_out4_72M ; // eeprom fifo
//
wire clk3_locked;
//
clk_wiz_0_3_1  clk_wiz_0_3_1_inst(
	// Clock out ports  
	.clk_out1_72M (clk3_out1_72M ), // BUFGCE // due to soft-startup 
	.clk_out2_144M(clk3_out2_144M), // BUFGCE // due to soft-startup
	.clk_out3_12M (clk3_out3_12M ), // BUFGCE // due to soft-startup
	.clk_out4_72M (clk3_out4_72M ), // BUFGCE // due to soft-startup 
	// Status and control signals     
	.resetn(clk_locked_pre),          
	.locked(clk3_locked),
	// Clock in ports
	.clk_in1_200M(clk_out1_200M) // no buf
);

//}

// clock pll4 //{

wire clk4_locked = 1'b1; // to remove


//}



// clock locked //{
wire clk_locked = clk1_locked & clk2_locked & clk3_locked & clk4_locked;
//}

// system clock //{
wire sys_clk	= clk_out3_10M;
//}

// system reset //{
wire reset_n	= clk_locked;
wire reset		= ~reset_n;
//}

// other alias clocks //{
wire mcs_clk             = clk3_out1_72M;
wire lan_clk             = clk3_out2_144M;
wire mcs_eeprom_fifo_clk = clk3_out4_72M;
wire xadc_clk            = clk_out4_10M;


//}





// clock for MTH SPI //{

wire base_sspi_clk; // base clock for slave SPI // 104MHz
wire p_sspi_clk;    // p_clk for SSPI // 13MHz = base / 8

wire clk_2_locked = 1'b1;

// clk_wiz_2_2
wire clk_2_2_locked; //$$ unused
clk_wiz_2_2  clk_wiz_2_2_inst (
	// Clock out ports  
	.clk_out1_104M(base_sspi_clk),  
	.clk_out2_13M (p_sspi_clk   ),  
	// Status and control signals     
	.resetn(clk_2_locked),          
	.locked(clk_2_2_locked),
	// Clock in ports
	.clk_in1(clk_out1_200M)
);

//}

wire host_clk            =  clk_out2_140M;



//}


///TODO: //-------------------------------------------------------//


/* TODO: end-point wires */ //{

// end-points : LAN vs HOST
//
// endpoint modules :
//
// (USB) ok_endpoint_wrapper : usb host interface <--> end-points //$$ removed
//    okHost okHI
//    ok...
//
// (LAN) lan_endpoint_wrapper : lan spi  interface <--> end-points
//    microblaze_mcs_1  soft_cpu_mcs_inst
//    mcs_io_bridge_ext  mcs_io_bridge_inst2
//    master_spi_wz850_ext  master_spi_wz850_inst
//    fifo_generator_3  LAN_fifo_wr_inst
//    fifo_generator_3  LAN_fifo_rd_inst
//
// (SSPI) slave_spi_mth_brd : MTH slave SPI <--> end-points
//   


//// TODO: LAN end-point wires: //{

// wire in //{
wire [31:0] w_port_wi_00_1; 
wire [31:0] w_port_wi_01_1; // S3100
wire [31:0] w_port_wi_02_1;
wire [31:0] w_port_wi_03_1; // S3100
wire [31:0] w_port_wi_04_1; 
wire [31:0] w_port_wi_05_1; 
wire [31:0] w_port_wi_06_1; 
wire [31:0] w_port_wi_07_1; 
wire [31:0] w_port_wi_08_1; 
wire [31:0] w_port_wi_09_1;
wire [31:0] w_port_wi_0A_1;
wire [31:0] w_port_wi_0B_1;
wire [31:0] w_port_wi_0C_1;
wire [31:0] w_port_wi_0D_1;
wire [31:0] w_port_wi_0E_1;
wire [31:0] w_port_wi_0F_1;
wire [31:0] w_port_wi_10_1;
wire [31:0] w_port_wi_11_1;
wire [31:0] w_port_wi_12_1; // MEM
wire [31:0] w_port_wi_13_1; // MEM
wire [31:0] w_port_wi_14_1;
wire [31:0] w_port_wi_15_1;
wire [31:0] w_port_wi_16_1; // S3100
wire [31:0] w_port_wi_17_1; // S3100
wire [31:0] w_port_wi_18_1;
wire [31:0] w_port_wi_19_1; // S3100
wire [31:0] w_port_wi_1A_1;
wire [31:0] w_port_wi_1B_1;
wire [31:0] w_port_wi_1C_1;
wire [31:0] w_port_wi_1D_1;
wire [31:0] w_port_wi_1E_1;
wire [31:0] w_port_wi_1F_1;
//}

// wire out //{
wire [31:0] w_port_wo_20_1; // S3100
wire [31:0] w_port_wo_21_1; // S3100
wire [31:0] w_port_wo_22_1; // S3100
wire [31:0] w_port_wo_23_1 = 32'b0; // not yet used
wire [31:0] w_port_wo_24_1; // S3100
wire [31:0] w_port_wo_25_1 = 32'b0; // not yet used
wire [31:0] w_port_wo_26_1 = 32'b0; // not yet used
wire [31:0] w_port_wo_27_1 = 32'b0; // not yet used
wire [31:0] w_port_wo_28_1 = 32'b0; // not yet used
wire [31:0] w_port_wo_29_1 = 32'b0; // not yet used
wire [31:0] w_port_wo_2A_1 = 32'b0; // not yet used
wire [31:0] w_port_wo_2B_1 = 32'b0; // not yet used
wire [31:0] w_port_wo_2C_1 = 32'b0; // not yet used
wire [31:0] w_port_wo_2D_1 = 32'b0; // not yet used
wire [31:0] w_port_wo_2E_1 = 32'b0; // not yet used
wire [31:0] w_port_wo_2F_1 = 32'b0; // not yet used
wire [31:0] w_port_wo_30_1 = 32'b0; // not yet used
wire [31:0] w_port_wo_31_1 = 32'b0; // not yet used
wire [31:0] w_port_wo_32_1 = 32'b0; // not yet used
wire [31:0] w_port_wo_33_1 = 32'b0; // not yet used
wire [31:0] w_port_wo_34_1 = 32'b0; // not yet used
wire [31:0] w_port_wo_35_1 = 32'b0; // not yet used
wire [31:0] w_port_wo_36_1 = 32'b0; // not yet used
wire [31:0] w_port_wo_37_1 = 32'b0; // not yet used
wire [31:0] w_port_wo_38_1 = 32'b0; // not yet used
wire [31:0] w_port_wo_39_1 = 32'b0; // not yet used
wire [31:0] w_port_wo_3A_1; // S3100
wire [31:0] w_port_wo_3B_1; // S3100
wire [31:0] w_port_wo_3C_1 = 32'b0; // not yet used
wire [31:0] w_port_wo_3D_1 = 32'b0; // not yet used
wire [31:0] w_port_wo_3E_1 = 32'b0; // not yet used
wire [31:0] w_port_wo_3F_1 = 32'b0; // not yet used
//}

// trig in //{
wire w_ck_40_1 = sys_clk       ; wire [31:0] w_port_ti_40_1; // S3100
wire w_ck_42_1 = base_sspi_clk ; wire [31:0] w_port_ti_42_1; // S3100
wire w_ck_53_1 = sys_clk       ; wire [31:0] w_port_ti_53_1; // MEM
//}

// trig out //{
wire w_ck_60_1 = sys_clk       ; wire [31:0] w_port_to_60_1; // S3100
wire w_ck_62_1 = base_sspi_clk ; wire [31:0] w_port_to_62_1; // S3100
wire w_ck_73_1 = sys_clk       ; wire [31:0] w_port_to_73_1; // MEM
//}

// pipe in //{
wire w_wr_8A_1; wire [31:0] w_port_pi_8A_1; // test fifo // MCS only
wire w_wr_93_1; wire [31:0] w_port_pi_93_1; // [MEM] MEM_PI
//}

// pipe out //{
wire w_rd_AA_1; wire [31:0] w_port_po_AA_1; // test fifo // MCS only
wire w_rd_B3_1; wire [31:0] w_port_po_B3_1; // [MEM] MEM_PO
//}

//$$ TODO: pipe clock //{

wire w_ck_pipe; // not used // mcs_eeprom_fifo_clk vs epPPck from lan_endpoint_wrapper
//wire w_ck_pipe = clk3_out1_72M;

//}

//}

//// TODO: ARM HOST interface wires: //{

// wire in //{
wire [31:0] w_ep00_hadrs = 32'h0000_0000; wire [31:0] w_ep00wire; // reserved
wire [31:0] w_ep01_hadrs = 32'h6070_0040; wire [31:0] w_ep01wire; // reserved // TEST_CON_WI   
wire [31:0] w_ep02_hadrs = 32'h6060_00A8; wire [31:0] w_ep02wire; // reserved // SSPI_CON_WI   
wire [31:0] w_ep03_hadrs = 32'h6060_00A0; wire [31:0] w_ep03wire; // reserved // BRD_CON_WI    
wire [31:0] w_ep04_hadrs = 32'h0000_0000; wire [31:0] w_ep04wire; // reserved
//
wire [31:0] w_ep12_hadrs = 32'h6070_0088; wire [31:0] w_ep12wire; // reserved // MEM_FDAT_WI   
wire [31:0] w_ep13_hadrs = 32'h6070_0080; wire [31:0] w_ep13wire; // reserved // MEM_WI_WI     
//
wire [31:0] w_ep16_hadrs = 32'h6060_0000; wire [31:0] w_ep16wire; // MSPI_EN_CS_WI // {SPI_CH_SELEC, SLOT_CS_MASK}
wire [31:0] w_ep17_hadrs = 32'h6070_0000; wire [31:0] w_ep17wire; // MSPI_CON_WI   // {Mx_SPI_MOSI_DATA_H, Mx_SPI_MOSI_DATA_L}
//
wire [31:0] w_ep1A_hadrs = 32'h6010_0008; wire [31:0] w_ep1Awire; // ERR_LED
wire [31:0] w_ep1B_hadrs = 32'h6010_0010; wire [31:0] w_ep1Bwire; // FPGA_LED
wire [31:0] w_ep1C_hadrs = 32'h6010_0030; wire [31:0] w_ep1Cwire; // HDL I/F OUT 
wire [31:0] w_ep1D_hadrs = 32'h6010_0068; wire [31:0] w_ep1Dwire; // {INTER_LOCK RELAY, INTER_LOCK LED}
wire [31:0] w_ep1E_hadrs = 32'h6030_0010; wire [31:0] w_ep1Ewire; // GPIB CONTROL // Control Read & Write  
//}

// wire out //{
wire [31:0] w_ep20_hadrs = 32'h6060_0080; wire [31:0] w_ep20wire; // reserved // F_IMAGE_ID_WO 
wire [31:0] w_ep21_hadrs = 32'h6070_0048; wire [31:0] w_ep21wire; // reserved // TEST_OUT_WO   
wire [31:0] w_ep22_hadrs = 32'h6060_0088; wire [31:0] w_ep22wire; // reserved // TIMESTAMP_WO  
wire [31:0] w_ep23_hadrs = 32'h6060_00B0; wire [31:0] w_ep23wire; // reserved // SSPI_FLAG_WO  
wire [31:0] w_ep24_hadrs = 32'h6070_0008; wire [31:0] w_ep24wire; // MSPI_FLAG_WO // {Mx_SPI_MISO_DATA_H, Mx_SPI_MISO_DATA_L}
//
wire [31:0] w_ep30_hadrs = 32'h6010_0000; wire [31:0] w_ep30wire; // {MAGIC CODE_H, MAGIC CODE_L}
wire [31:0] w_ep31_hadrs = 32'h6010_0018; wire [31:0] w_ep31wire; // MASTER MODE, LAN IP Address 
wire [31:0] w_ep32_hadrs = 32'h6010_0020; wire [31:0] w_ep32wire; // {FPGA_IMAGE_ID_H, FPGA_IMAGE_ID_L}
wire [31:0] w_ep33_hadrs = 32'h6010_0038; wire [31:0] w_ep33wire; // HDL I/F IN
wire [31:0] w_ep34_hadrs = 32'h6010_0040; wire [31:0] w_ep34wire; // {FAN#1 FAN SPEED, FAN#0 FAN SPEED}
wire [31:0] w_ep35_hadrs = 32'h6010_0048; wire [31:0] w_ep35wire; // {FAN#3 FAN SPEED, FAN#2 FAN SPEED}
wire [31:0] w_ep36_hadrs = 32'h6010_0050; wire [31:0] w_ep36wire; // {FAN#5 FAN SPEED, FAN#4 FAN SPEED}
wire [31:0] w_ep37_hadrs = 32'h6010_0058; wire [31:0] w_ep37wire; // {FAN#7 FAN SPEED, FAN#6 FAN SPEED}
wire [31:0] w_ep38_hadrs = 32'h6010_0060; wire [31:0] w_ep38wire; // INTER_LOCK
wire [31:0] w_ep39_hadrs = 32'h6030_0000; wire [31:0] w_ep39wire; // GPIB_STATUS
wire [31:0] w_ep3A_hadrs = 32'h6060_0090; wire [31:0] w_ep3Awire; // reserved // XADC_TEMP_WO  
wire [31:0] w_ep3B_hadrs = 32'h6060_0098; wire [31:0] w_ep3Bwire; // reserved // XADC_VOLT_WO  
//}

// trig in //{
wire [31:0] w_ep40_hadrs = 32'h6070_0050; wire w_ep40ck = sys_clk      ; wire [31:0] w_ep40trig;  // reserved // TEST_TI       
wire [31:0] w_ep42_hadrs = 32'h6070_0010; wire w_ep42ck = base_sspi_clk; wire [31:0] w_ep42trig;  // MSPI_TI // Mx_SPI_Trig
//
wire [31:0] w_ep50_hadrs = 32'h6010_0028; wire w_ep50ck = sys_clk      ; wire [31:0] w_ep50trig;  // S/W Reset
wire [31:0] w_ep51_hadrs = 32'h60A0_0000; wire w_ep51ck = sys_clk      ; wire [31:0] w_ep51trig;  // {PRE_Trig, Trig}
wire [31:0] w_ep52_hadrs = 32'h60A0_0008; wire w_ep52ck = sys_clk      ; wire [31:0] w_ep52trig;  // SOT
wire [31:0] w_ep53_hadrs = 32'h6070_0090; wire w_ep53ck = sys_clk      ; wire [31:0] w_ep53trig;  // reserved // MEM_TI        

//}

// trig out //{
wire [31:0] w_ep60_hadrs = 32'h6070_0058; wire w_ep60ck = sys_clk      ; wire [31:0] w_ep60trig;  // reserved // TEST_TO       
wire [31:0] w_ep62_hadrs = 32'h6070_0018; wire w_ep62ck = base_sspi_clk; wire [31:0] w_ep62trig;  // MSPI_TO // Mx_SPI_DONE
//
wire [31:0] w_ep73_hadrs = 32'h6070_0098; wire w_ep73ck = sys_clk      ; wire [31:0] w_ep73trig;  // reserved // MEM_TO        

//}

// pipe in //{
wire [31:0] w_ep93_hadrs = 32'h6070_00A0; wire w_ep93wr; wire [31:0] w_ep93pipe; // input wire [31:0] // output wire // output wire [31:0] // MEM_PI        
//}

// pipe out //{
wire [31:0] w_epB3_hadrs = 32'h6070_00A8; wire w_epB3rd; wire [31:0] w_epB3pipe; // input wire [31:0] // output wire // input wire [31:0] // MEM_PO        
//}

// pipe clk //{
wire w_ck_core;
//}

//}

//}


///TODO: //-------------------------------------------------------//


/* TODO: END-POINTS wrapper for EP_LAN */ //{

// offset definition for mcs_io_bridge.v //{

//#define MCS_IO_INST_OFFSET              0x00000000 // for LAN
//#define MCS_IO_INST_OFFSET_CMU          0x00010000 // for CMU
//#define MCS_IO_INST_OFFSET_PGU          0x00020000 // for PGU
//#define MCS_IO_INST_OFFSET_EXT          0x00030000 // for MHVSU_BASE (port end-points + lan end-points)
//#define MCS_IO_INST_OFFSET_EXT_CMU      0x00040000 // for NEW CMU (port end-points + lan end-points)
//#define MCS_IO_INST_OFFSET_EXT_PGU      0x00050000 // for NEW PGU (port end-points + lan end-points) //$$ to come

//}

// lan_endpoint_wrapper   //{

wire [47:0] w_adrs_offset_mac_48b       ; // BASE = {8'h00,8'h08,8'hDC,8'h00,8'hAB,8'hCD}; // 00:08:DC:00:xx:yy ??48 bits
wire [31:0] w_adrs_offset_ip_32b        ; // BASE = {8'd192,8'd168,8'd168,8'd112};         // 192.168.168.112 or C0:A8:A8:70 ??32 bits
wire [15:0] w_offset_lan_timeout_rtr_16b; //
wire [15:0] w_offset_lan_timeout_rcr_16b; //

wire  EP_LAN_MOSI ; 
wire  EP_LAN_SCLK ; 
wire  EP_LAN_CS_B ; 
wire  EP_LAN_INT_B; 
wire  EP_LAN_RST_B; 
wire  EP_LAN_MISO ; 

// asign for pin map 
assign  LAN_RST_B   = EP_LAN_RST_B  ;
assign  LAN_SSN_B   = EP_LAN_CS_B   ;
assign  LAN_MOSI    = EP_LAN_MOSI   ;
assign  LAN_SCLK    = EP_LAN_SCLK   ;
//
assign  EP_LAN_INT_B  = LAN_INT_B   ;
assign  EP_LAN_MISO   = LAN_MISO    ;

lan_endpoint_wrapper #(
	//.MCS_IO_INST_OFFSET			(32'h_0004_0000), //$$ for CMU2020
	//.MCS_IO_INST_OFFSET			(32'h_0005_0000), //$$ for PGU2020 or S3000-PGU
	.MCS_IO_INST_OFFSET			(32'h_0006_0000), //$$ for S3100-CPU-BASE
	.FPGA_IMAGE_ID              (FPGA_IMAGE_ID)  
) lan_endpoint_wrapper_inst(
	
	//// pins and config //{
	
	// EP_LAN pins 
	.EP_LAN_MOSI   (EP_LAN_MOSI ), // output wire     EP_LAN_MOSI  ,
	.EP_LAN_SCLK   (EP_LAN_SCLK ), // output wire     EP_LAN_SCLK  ,
	.EP_LAN_CS_B   (EP_LAN_CS_B ), // output wire     EP_LAN_CS_B  ,
	.EP_LAN_INT_B  (EP_LAN_INT_B), // input  wire     EP_LAN_INT_B ,
	.EP_LAN_RST_B  (EP_LAN_RST_B), // output wire     EP_LAN_RST_B ,
	.EP_LAN_MISO   (EP_LAN_MISO ), // input  wire     EP_LAN_MISO  ,
	
	// for common 
	.clk           (sys_clk), // 10MHz
	.reset_n       (reset_n),
	
	// soft CPU clock
	.mcs_clk       (mcs_clk), // 72MHz
	
	// dedicated LAN clock 
	.lan_clk       (lan_clk), // 144MHz
	
	// MAC/IP address offsets
	.i_adrs_offset_mac_48b  (w_adrs_offset_mac_48b), // input  wire [47:0]  
	.i_adrs_offset_ip_32b   (w_adrs_offset_ip_32b ), // input  wire [31:0]  
	// LAN timeout setup
	.i_offset_lan_timeout_rtr_16b  (w_offset_lan_timeout_rtr_16b), // input  wire [15:0]
	.i_offset_lan_timeout_rcr_16b  (w_offset_lan_timeout_rcr_16b), // input  wire [15:0]
	
	//}

	// Wire In 		0x00 - 0x1F  //{
	.ep00wire (w_port_wi_00_1), // output wire [31:0]
	.ep01wire (w_port_wi_01_1), // output wire [31:0]
	.ep02wire (w_port_wi_02_1), // output wire [31:0]
	.ep03wire (w_port_wi_03_1), // output wire [31:0]
	.ep04wire (w_port_wi_04_1), // output wire [31:0]
	.ep05wire (w_port_wi_05_1), // output wire [31:0]
	.ep06wire (w_port_wi_06_1), // output wire [31:0]
	.ep07wire (w_port_wi_07_1), // output wire [31:0]
	.ep08wire (w_port_wi_08_1), // output wire [31:0]
	.ep09wire (w_port_wi_09_1), // output wire [31:0]
	.ep0Awire (w_port_wi_0A_1), // output wire [31:0]
	.ep0Bwire (w_port_wi_0B_1), // output wire [31:0]
	.ep0Cwire (w_port_wi_0C_1), // output wire [31:0]
	.ep0Dwire (w_port_wi_0D_1), // output wire [31:0]
	.ep0Ewire (w_port_wi_0E_1), // output wire [31:0]
	.ep0Fwire (w_port_wi_0F_1), // output wire [31:0]
	.ep10wire (w_port_wi_10_1), // output wire [31:0]
	.ep11wire (w_port_wi_11_1), // output wire [31:0]
	.ep12wire (w_port_wi_12_1), // output wire [31:0]
	.ep13wire (w_port_wi_13_1), // output wire [31:0]
	.ep14wire (w_port_wi_14_1), // output wire [31:0]
	.ep15wire (w_port_wi_15_1), // output wire [31:0]
	.ep16wire (w_port_wi_16_1), // output wire [31:0]
	.ep17wire (w_port_wi_17_1), // output wire [31:0]
	.ep18wire (w_port_wi_18_1), // output wire [31:0]
	.ep19wire (w_port_wi_19_1), // output wire [31:0]
	.ep1Awire (w_port_wi_1A_1), // output wire [31:0]
	.ep1Bwire (w_port_wi_1B_1), // output wire [31:0]
	.ep1Cwire (w_port_wi_1C_1), // output wire [31:0]
	.ep1Dwire (w_port_wi_1D_1), // output wire [31:0]
	.ep1Ewire (w_port_wi_1E_1), // output wire [31:0]
	.ep1Fwire (w_port_wi_1F_1), // output wire [31:0]
	//}
	
	// Wire Out 	0x20 - 0x3F //{
	.ep20wire (w_port_wo_20_1), // input wire [31:0]
	.ep21wire (w_port_wo_21_1), // input wire [31:0]
	.ep22wire (w_port_wo_22_1), // input wire [31:0]
	.ep23wire (w_port_wo_23_1), // input wire [31:0]
	.ep24wire (w_port_wo_24_1), // input wire [31:0]
	.ep25wire (w_port_wo_25_1), // input wire [31:0]
	.ep26wire (w_port_wo_26_1), // input wire [31:0]
	.ep27wire (w_port_wo_27_1), // input wire [31:0]
	.ep28wire (w_port_wo_28_1), // input wire [31:0]
	.ep29wire (w_port_wo_29_1), // input wire [31:0]
	.ep2Awire (w_port_wo_2A_1), // input wire [31:0]
	.ep2Bwire (w_port_wo_2B_1), // input wire [31:0]
	.ep2Cwire (w_port_wo_2C_1), // input wire [31:0]
	.ep2Dwire (w_port_wo_2D_1), // input wire [31:0]
	.ep2Ewire (w_port_wo_2E_1), // input wire [31:0]
	.ep2Fwire (w_port_wo_2F_1), // input wire [31:0]
	.ep30wire (w_port_wo_30_1), // input wire [31:0]
	.ep31wire (w_port_wo_31_1), // input wire [31:0]
	.ep32wire (w_port_wo_32_1), // input wire [31:0]
	.ep33wire (w_port_wo_33_1), // input wire [31:0]
	.ep34wire (w_port_wo_34_1), // input wire [31:0]
	.ep35wire (w_port_wo_35_1), // input wire [31:0]
	.ep36wire (w_port_wo_36_1), // input wire [31:0]
	.ep37wire (w_port_wo_37_1), // input wire [31:0]
	.ep38wire (w_port_wo_38_1), // input wire [31:0]
	.ep39wire (w_port_wo_39_1), // input wire [31:0]
	.ep3Awire (w_port_wo_3A_1), // input wire [31:0]
	.ep3Bwire (w_port_wo_3B_1), // input wire [31:0]
	.ep3Cwire (w_port_wo_3C_1), // input wire [31:0]
	.ep3Dwire (w_port_wo_3D_1), // input wire [31:0]
	.ep3Ewire (w_port_wo_3E_1), // input wire [31:0]
	.ep3Fwire (w_port_wo_3F_1), // input wire [31:0]
	//}
	
	// Trigger In 	0x40 - 0x5F //{
	.ep40ck (w_ck_40_1), .ep40trig (w_port_ti_40_1), // input wire, output wire [31:0],
	.ep41ck (1'b0),      .ep41trig (), // input wire, output wire [31:0],
	.ep42ck (w_ck_42_1), .ep42trig (w_port_ti_42_1), // input wire, output wire [31:0],
	.ep43ck (1'b0),      .ep43trig (), // input wire, output wire [31:0],
	.ep44ck (1'b0),      .ep44trig (), // input wire, output wire [31:0],
	.ep45ck (1'b0),      .ep45trig (), // input wire, output wire [31:0],
	.ep46ck (1'b0),      .ep46trig (), // input wire, output wire [31:0],
	.ep47ck (1'b0),      .ep47trig (), // input wire, output wire [31:0],
	.ep48ck (1'b0),      .ep48trig (), // input wire, output wire [31:0],
	.ep49ck (1'b0),      .ep49trig (), // input wire, output wire [31:0],
	.ep4Ack (1'b0),      .ep4Atrig (), // input wire, output wire [31:0],
	.ep4Bck (1'b0),      .ep4Btrig (), // input wire, output wire [31:0],
	.ep4Cck (1'b0),      .ep4Ctrig (), // input wire, output wire [31:0],
	.ep4Dck (1'b0),      .ep4Dtrig (), // input wire, output wire [31:0],
	.ep4Eck (1'b0),      .ep4Etrig (), // input wire, output wire [31:0],
	.ep4Fck (1'b0),      .ep4Ftrig (), // input wire, output wire [31:0],
	.ep50ck (1'b0),      .ep50trig (), // input wire, output wire [31:0],
	.ep51ck (1'b0),      .ep51trig (), // input wire, output wire [31:0],
	.ep52ck (1'b0),      .ep52trig (), // input wire, output wire [31:0],
	.ep53ck (w_ck_53_1), .ep53trig (w_port_ti_53_1), // input wire, output wire [31:0],
	.ep54ck (1'b0),      .ep54trig (), // input wire, output wire [31:0],
	.ep55ck (1'b0),      .ep55trig (), // input wire, output wire [31:0],
	.ep56ck (1'b0),      .ep56trig (), // input wire, output wire [31:0],
	.ep57ck (1'b0),      .ep57trig (), // input wire, output wire [31:0],
	.ep58ck (1'b0),      .ep58trig (), // input wire, output wire [31:0],
	.ep59ck (1'b0),      .ep59trig (), // input wire, output wire [31:0],
	.ep5Ack (1'b0),      .ep5Atrig (), // input wire, output wire [31:0],
	.ep5Bck (1'b0),      .ep5Btrig (), // input wire, output wire [31:0],
	.ep5Cck (1'b0),      .ep5Ctrig (), // input wire, output wire [31:0],
	.ep5Dck (1'b0),      .ep5Dtrig (), // input wire, output wire [31:0],
	.ep5Eck (1'b0),      .ep5Etrig (), // input wire, output wire [31:0],
	.ep5Fck (1'b0),      .ep5Ftrig (), // input wire, output wire [31:0],
	//}
	
	// Trigger Out 	0x60 - 0x7F //{
	.ep60ck (w_ck_60_1), .ep60trig (w_port_to_60_1), // input wire, input wire [31:0],
	.ep61ck (1'b0),      .ep61trig (32'b0), // input wire, input wire [31:0],
	.ep62ck (w_ck_62_1), .ep62trig (w_port_to_62_1), // input wire, input wire [31:0],
	.ep63ck (1'b0),      .ep63trig (32'b0), // input wire, input wire [31:0],
	.ep64ck (1'b0),      .ep64trig (32'b0), // input wire, input wire [31:0],
	.ep65ck (1'b0),      .ep65trig (32'b0), // input wire, input wire [31:0],
	.ep66ck (1'b0),      .ep66trig (32'b0), // input wire, input wire [31:0],
	.ep67ck (1'b0),      .ep67trig (32'b0), // input wire, input wire [31:0],
	.ep68ck (1'b0),      .ep68trig (32'b0), // input wire, input wire [31:0],
	.ep69ck (1'b0),      .ep69trig (32'b0), // input wire, input wire [31:0],
	.ep6Ack (1'b0),      .ep6Atrig (32'b0), // input wire, input wire [31:0],
	.ep6Bck (1'b0),      .ep6Btrig (32'b0), // input wire, input wire [31:0],
	.ep6Cck (1'b0),      .ep6Ctrig (32'b0), // input wire, input wire [31:0],
	.ep6Dck (1'b0),      .ep6Dtrig (32'b0), // input wire, input wire [31:0],
	.ep6Eck (1'b0),      .ep6Etrig (32'b0), // input wire, input wire [31:0],
	.ep6Fck (1'b0),      .ep6Ftrig (32'b0), // input wire, input wire [31:0],
	.ep70ck (1'b0),      .ep70trig (32'b0), // input wire, input wire [31:0],
	.ep71ck (1'b0),      .ep71trig (32'b0), // input wire, input wire [31:0],
	.ep72ck (1'b0),      .ep72trig (32'b0), // input wire, input wire [31:0],
	.ep73ck (w_ck_73_1), .ep73trig (w_port_to_73_1), // input wire, input wire [31:0],
	.ep74ck (1'b0),      .ep74trig (32'b0), // input wire, input wire [31:0],
	.ep75ck (1'b0),      .ep75trig (32'b0), // input wire, input wire [31:0],
	.ep76ck (1'b0),      .ep76trig (32'b0), // input wire, input wire [31:0],
	.ep77ck (1'b0),      .ep77trig (32'b0), // input wire, input wire [31:0],
	.ep78ck (1'b0),      .ep78trig (32'b0), // input wire, input wire [31:0],
	.ep79ck (1'b0),      .ep79trig (32'b0), // input wire, input wire [31:0],
	.ep7Ack (1'b0),      .ep7Atrig (32'b0), // input wire, input wire [31:0],
	.ep7Bck (1'b0),      .ep7Btrig (32'b0), // input wire, input wire [31:0],
	.ep7Cck (1'b0),      .ep7Ctrig (32'b0), // input wire, input wire [31:0],
	.ep7Dck (1'b0),      .ep7Dtrig (32'b0), // input wire, input wire [31:0],
	.ep7Eck (1'b0),      .ep7Etrig (32'b0), // input wire, input wire [31:0],
	.ep7Fck (1'b0),      .ep7Ftrig (32'b0), // input wire, input wire [31:0],
	//}
	
	// Pipe In 		0x80 - 0x9F //{
	.ep80wr (),          .ep80pipe (), // output wire, output wire [31:0],
	.ep81wr (),          .ep81pipe (), // output wire, output wire [31:0],
	.ep82wr (),          .ep82pipe (), // output wire, output wire [31:0],
	.ep83wr (),          .ep83pipe (), // output wire, output wire [31:0],
	.ep84wr (),          .ep84pipe (), // output wire, output wire [31:0],
	.ep85wr (),          .ep85pipe (), // output wire, output wire [31:0],
	.ep86wr (),          .ep86pipe (), // output wire, output wire [31:0],
	.ep87wr (),          .ep87pipe (), // output wire, output wire [31:0],
	.ep88wr (),          .ep88pipe (), // output wire, output wire [31:0],
	.ep89wr (),          .ep89pipe (), // output wire, output wire [31:0],
	.ep8Awr (w_wr_8A_1), .ep8Apipe (w_port_pi_8A_1), // output wire, output wire [31:0],
	.ep8Bwr (),          .ep8Bpipe (), // output wire, output wire [31:0],
	.ep8Cwr (),          .ep8Cpipe (), // output wire, output wire [31:0],
	.ep8Dwr (),          .ep8Dpipe (), // output wire, output wire [31:0],
	.ep8Ewr (),          .ep8Epipe (), // output wire, output wire [31:0],
	.ep8Fwr (),          .ep8Fpipe (), // output wire, output wire [31:0],
	.ep90wr (),          .ep90pipe (), // output wire, output wire [31:0],
	.ep91wr (),          .ep91pipe (), // output wire, output wire [31:0],
	.ep92wr (),          .ep92pipe (), // output wire, output wire [31:0],
	.ep93wr (w_wr_93_1), .ep93pipe (w_port_pi_93_1), // output wire, output wire [31:0],
	.ep94wr (),          .ep94pipe (), // output wire, output wire [31:0],
	.ep95wr (),          .ep95pipe (), // output wire, output wire [31:0],
	.ep96wr (),          .ep96pipe (), // output wire, output wire [31:0],
	.ep97wr (),          .ep97pipe (), // output wire, output wire [31:0],
	.ep98wr (),          .ep98pipe (), // output wire, output wire [31:0],
	.ep99wr (),          .ep99pipe (), // output wire, output wire [31:0],
	.ep9Awr (),          .ep9Apipe (), // output wire, output wire [31:0],
	.ep9Bwr (),          .ep9Bpipe (), // output wire, output wire [31:0],
	.ep9Cwr (),          .ep9Cpipe (), // output wire, output wire [31:0],
	.ep9Dwr (),          .ep9Dpipe (), // output wire, output wire [31:0],
	.ep9Ewr (),          .ep9Epipe (), // output wire, output wire [31:0],
	.ep9Fwr (),          .ep9Fpipe (), // output wire, output wire [31:0],
	//}
	
	// Pipe Out 	0xA0 - 0xBF //{
	.epA0rd (),          .epA0pipe (32'b0), // output wire, input wire [31:0],
	.epA1rd (),          .epA1pipe (32'b0), // output wire, input wire [31:0],
	.epA2rd (),          .epA2pipe (32'b0), // output wire, input wire [31:0],
	.epA3rd (),          .epA3pipe (32'b0), // output wire, input wire [31:0],
	.epA4rd (),          .epA4pipe (32'b0), // output wire, input wire [31:0],
	.epA5rd (),          .epA5pipe (32'b0), // output wire, input wire [31:0],
	.epA6rd (),          .epA6pipe (32'b0), // output wire, input wire [31:0],
	.epA7rd (),          .epA7pipe (32'b0), // output wire, input wire [31:0],
	.epA8rd (),          .epA8pipe (32'b0), // output wire, input wire [31:0],
	.epA9rd (),          .epA9pipe (32'b0), // output wire, input wire [31:0],
	.epAArd (w_rd_AA_1), .epAApipe (w_port_po_AA_1), // output wire, input wire [31:0],
	.epABrd (),          .epABpipe (32'b0), // output wire, input wire [31:0],
	.epACrd (),          .epACpipe (32'b0), // output wire, input wire [31:0],
	.epADrd (),          .epADpipe (32'b0), // output wire, input wire [31:0],
	.epAErd (),          .epAEpipe (32'b0), // output wire, input wire [31:0],
	.epAFrd (),          .epAFpipe (32'b0), // output wire, input wire [31:0],
	.epB0rd (),          .epB0pipe (32'b0), // output wire, input wire [31:0],
	.epB1rd (),          .epB1pipe (32'b0), // output wire, input wire [31:0],
	.epB2rd (),          .epB2pipe (32'b0), // output wire, input wire [31:0],
	.epB3rd (w_rd_B3_1), .epB3pipe (w_port_po_B3_1), // output wire, input wire [31:0],
	.epB4rd (),          .epB4pipe (32'b0), // output wire, input wire [31:0],
	.epB5rd (),          .epB5pipe (32'b0), // output wire, input wire [31:0],
	.epB6rd (),          .epB6pipe (32'b0), // output wire, input wire [31:0],
	.epB7rd (),          .epB7pipe (32'b0), // output wire, input wire [31:0],
	.epB8rd (),          .epB8pipe (32'b0), // output wire, input wire [31:0],
	.epB9rd (),          .epB9pipe (32'b0), // output wire, input wire [31:0],
	.epBArd (),          .epBApipe (32'b0), // output wire, input wire [31:0],
	.epBBrd (),          .epBBpipe (32'b0), // output wire, input wire [31:0],
	.epBCrd (),          .epBCpipe (32'b0), // output wire, input wire [31:0],
	.epBDrd (),          .epBDpipe (32'b0), // output wire, input wire [31:0],
	.epBErd (),          .epBEpipe (32'b0), // output wire, input wire [31:0],
	.epBFrd (),          .epBFpipe (32'b0), // output wire, input wire [31:0],
	//}
	
	// Pipe clock output //{
	.epPPck (w_ck_pipe) //output wire // sync with write/read of pipe // 72MHz
	//}
	);

//}

// assign //{

assign w_adrs_offset_mac_48b[47:16] = {8'h00,8'h00,8'h00,8'h00}; // assign high 32b
assign w_adrs_offset_ip_32b [31:16] = {8'h00,8'h00}            ; // assign high 16b
assign w_offset_lan_timeout_rtr_16b = 16'd0;
assign w_offset_lan_timeout_rcr_16b = 16'd0;

//}

////

//}


/* TODO: TEST FIFO */ //{

// emulate LAN-fifo from/to ADC-fifo
// test-place ADC-fifo with TEST-fifo, which can be read and written.
//
// fifo_generator_4 : test
// 32 bits
// 4096 depth = 2^12
// 2^12 * 4 byte = 16KB
		
fifo_generator_4 TEST_fifo_inst(
  //.rst       (~reset_n | ~w_LAN_RSTn | w_FIFO_reset), // input wire rst
  .rst       (~reset_n), // input wire rst
  .wr_clk    (mcs_clk),  // input wire wr_clk
  .wr_en     (w_wr_8A_1),      // input wire wr_en
  .din       (w_port_pi_8A_1), // input wire [31 : 0] din
  .rd_clk    (mcs_clk),  // input wire rd_clk
  .rd_en     (w_rd_AA_1),      // input wire rd_en
  .dout      (w_port_po_AA_1), // output wire [31 : 0] dout
  .full      (),  // output wire full
  .wr_ack    (),  // output wire wr_ack
  .empty     (),  // output wire empty
  .valid     ()   // output wire valid
);

//}


///TODO: //-------------------------------------------------------//


/* TODO: mapping endpoints to signals for S3100-CPU-BASE board */ //{

// most control in signals

//// BRD_CON //{
wire [31:0] w_BRD_CON_WI = w_port_wi_03_1 | w_ep03wire; // board control // logic or
// reset wires 
// endpoint mux enable : LAN(MCS) vs USB

// sub wires 
//wire w_HW_reset              = w_BRD_CON_WI[0];

// reset wires 
//wire w_rst_adc      = w_BRD_CON_WI[1]; 
//wire w_rst_dwave    = w_BRD_CON_WI[2]; 
//wire w_rst_bias     = w_BRD_CON_WI[3]; 
//wire w_rst_spo      = w_BRD_CON_WI[4]; 
//// wire w_rst_mcs_ep   = w_BRD_CON_WI[]; 

// endpoint mux enable : LAN(MCS) vs USB
wire w_mcs_ep_po_en = w_BRD_CON_WI[ 8]; 
wire w_mcs_ep_pi_en = w_BRD_CON_WI[ 9]; 
wire w_mcs_ep_to_en = w_BRD_CON_WI[10]; 
wire w_mcs_ep_ti_en = w_BRD_CON_WI[11];  
wire w_mcs_ep_wo_en = w_BRD_CON_WI[12]; 
wire w_mcs_ep_wi_en = w_BRD_CON_WI[13]; 

//}

//// MCS_SETUP_WI //{

// MCS control 
wire [31:0] w_MCS_SETUP_WI = w_port_wi_19_1; //$$ dedicated to MCS. updated by MCS boot-up.
// bit[3:0]= slot_id, range of 00~99, set from EEPROM via MCS
// ...
// bit[8]  = sel__H_LAN_for_EEPROM_fifo (or USB)  //$$ no USB in S3100
// bit[9]  = sel__H_EEPROM_on_TP (or on Base)
// bit[10] = sel__H_LAN_on_BASE_BD (or on module) //$$ always LAN_on_BASE in S3100
// ...
// bit[31:16]=board_id, range of 0000~9999, set from EEPROM via MCS

wire [3:0]  w_slot_id             = w_MCS_SETUP_WI[3:0];   // not yet
//$$ wire w_sel__H_LAN_for_EEPROM_fifo = w_MCS_SETUP_WI[8];
//$$ wire w_sel__H_EEPROM_on_TP        = w_MCS_SETUP_WI[9];     // not yet
//$$ wire w_sel__H_LAN_on_BASE_BD      = w_MCS_SETUP_WI[10];    // not yet // ignored in S3100
wire [15:0] w_board_id            = w_MCS_SETUP_WI[31:16]; // not yet

// for dedicated LAN setup from MCS
assign w_adrs_offset_mac_48b[15:0] = {8'h00, 4'h0, w_slot_id}; // assign low 16b
assign w_adrs_offset_ip_32b [15:0] = {8'h00, 4'h0, w_slot_id}; // assign low 16b

//}

//// TEST wires //{

// check IDs end-point //{
wire [31:0] w_F_IMAGE_ID_WO = FPGA_IMAGE_ID ;
//
assign w_port_wo_20_1   = w_F_IMAGE_ID_WO; //$$ LAN
assign       w_ep20wire = w_F_IMAGE_ID_WO; //$$ arm host
assign       w_ep32wire = w_F_IMAGE_ID_WO; //$$ arm host

//}

// timestamp //{
(* keep = "true" *) wire [31:0] w_TIMESTAMP_WO;
assign w_port_wo_22_1     = w_TIMESTAMP_WO ;
assign       w_ep22wire   = w_TIMESTAMP_WO ;
//}

// TEST counter end-point //{
wire [31:0] w_TEST_CON_WI = (w_mcs_ep_wi_en)? w_port_wi_01_1 : w_ep01wire;
//
wire [31:0] w_TEST_OUT_WO;
assign w_port_wo_21_1    = w_TEST_OUT_WO ;
assign       w_ep21wire  = w_TEST_OUT_WO ; 

wire [31:0] w_TEST_TI    = ( w_mcs_ep_ti_en)? w_port_ti_40_1 : w_ep40trig;

wire [31:0] w_TEST_TO;
assign w_port_to_60_1    = ( w_mcs_ep_to_en)? w_TEST_TO : 32'h0000_0000; 
assign       w_ep60trig  = (!w_mcs_ep_to_en)? w_TEST_TO : 32'h0000_0000;

//}


//}


//// ARM core wires //{

// wi pin
assign BASE_F_LED_ERR   = ~w_ep1Awire[ 0]; // low active 
assign INTER_LED_O      = ~w_ep1Dwire[ 0]; // low active
assign INTER_RELAY_O    =  w_ep1Dwire[16];
assign FPGA_H_OUT1      =  w_ep1Cwire[ 0];
assign FPGA_H_OUT2      =  w_ep1Cwire[ 1];
assign FPGA_H_OUT3      =  w_ep1Cwire[ 2];
assign FPGA_H_OUT4      =  w_ep1Cwire[ 3];

// wires
wire [31:0] w_FPGA_LED       = ~w_ep1Bwire[31:0]; // low active
wire [15:0] w_GPIB_CONTROL   =  w_ep1Ewire[15:0];
wire [1:0]  w_GPIB_REM_ALT   =  w_ep1Ewire[1:0];
wire [1:0]  w_GPIB_TADCS_ALT =  w_ep1Ewire[3:2];
wire [1:0]  w_GPIB_LADCS_ALT =  w_ep1Ewire[5:4];
wire [1:0]  w_GPIB_TRIG_ALT  =  w_ep1Ewire[7:6];

// wo
assign w_ep30wire = 32'h33AA_CC55; // known pattern
//
assign w_ep31wire[31:10] = 22'b0;
assign w_ep31wire[    9] = BUF_MASTER1;
assign w_ep31wire[    8] = BUF_MASTER0;
assign w_ep31wire[ 7: 4] = 4'b0;
assign w_ep31wire[    3] = BUF_LAN_IP3;
assign w_ep31wire[    2] = BUF_LAN_IP2;
assign w_ep31wire[    1] = BUF_LAN_IP1;
assign w_ep31wire[    0] = BUF_LAN_IP0;
//
assign w_ep33wire[31:4] = 28'b0;
assign w_ep33wire[   3] = FPGA_H_IN4;
assign w_ep33wire[   2] = FPGA_H_IN3;
assign w_ep33wire[   1] = FPGA_H_IN2;
assign w_ep33wire[   0] = FPGA_H_IN1;
//
wire [15:0] w_FAN_SPEED0; // 16'b0;
wire [15:0] w_FAN_SPEED1; // 16'b0;
wire [15:0] w_FAN_SPEED2; // 16'b0;
wire [15:0] w_FAN_SPEED3; // 16'b0;
wire [15:0] w_FAN_SPEED4; // 16'b0;
wire [15:0] w_FAN_SPEED5; // 16'b0;
wire [15:0] w_FAN_SPEED6; // 16'b0;
wire [15:0] w_FAN_SPEED7; // 16'b0;
rpm_counter rpm_counter__inst0 (.clk(sys_clk),.reset_n(reset_n),.i_pulse(FPGA_FAN_SENS_0),.o_rpm_count(w_FAN_SPEED0) );
rpm_counter rpm_counter__inst1 (.clk(sys_clk),.reset_n(reset_n),.i_pulse(FPGA_FAN_SENS_1),.o_rpm_count(w_FAN_SPEED1) );
rpm_counter rpm_counter__inst2 (.clk(sys_clk),.reset_n(reset_n),.i_pulse(FPGA_FAN_SENS_2),.o_rpm_count(w_FAN_SPEED2) );
rpm_counter rpm_counter__inst3 (.clk(sys_clk),.reset_n(reset_n),.i_pulse(FPGA_FAN_SENS_3),.o_rpm_count(w_FAN_SPEED3) );
rpm_counter rpm_counter__inst4 (.clk(sys_clk),.reset_n(reset_n),.i_pulse(FPGA_FAN_SENS_4),.o_rpm_count(w_FAN_SPEED4) );
rpm_counter rpm_counter__inst5 (.clk(sys_clk),.reset_n(reset_n),.i_pulse(FPGA_FAN_SENS_5),.o_rpm_count(w_FAN_SPEED5) );
rpm_counter rpm_counter__inst6 (.clk(sys_clk),.reset_n(reset_n),.i_pulse(FPGA_FAN_SENS_6),.o_rpm_count(w_FAN_SPEED6) );
rpm_counter rpm_counter__inst7 (.clk(sys_clk),.reset_n(reset_n),.i_pulse(FPGA_FAN_SENS_7),.o_rpm_count(w_FAN_SPEED7) );
assign w_ep34wire = {w_FAN_SPEED1,w_FAN_SPEED0};
assign w_ep35wire = {w_FAN_SPEED3,w_FAN_SPEED2};
assign w_ep36wire = {w_FAN_SPEED5,w_FAN_SPEED4};
assign w_ep37wire = {w_FAN_SPEED7,w_FAN_SPEED6};
//
assign w_ep38wire[31:1] = 31'b0;
assign w_ep38wire[   0] = INTER_LOCK_ON;
//
wire [31:0] w_GPIB_STATUS ; //  = 16'b0; // test // GPIB_TRIG, GPIB_DCAS, GPIB_LADCS, GPIB_TADCS, GPIB_REM
assign w_GPIB_STATUS[31:5] = 27'b0;
assign w_GPIB_STATUS[4]    = GPIB_TRIG ;
assign w_GPIB_STATUS[3]    = GPIB_DCAS ;
assign w_GPIB_STATUS[2]    = GPIB_LADCS;
assign w_GPIB_STATUS[1]    = GPIB_TADCS;
assign w_GPIB_STATUS[0]    = GPIB_REM  ;
assign w_ep39wire = w_GPIB_STATUS;
//wire [15:0] w_GPIB_SW      = 16'b0; // test //$$ from outside
//assign w_ep39wire = {w_GPIB_SW, w_GPIB_STATUS};


// ti
wire w_SW_RESET = w_ep50trig[0];
//
assign PRE_TRIG  = w_ep51trig[8];
assign TRIG      = w_ep51trig[0];
assign SOT       = w_ep52trig[0];

//}


//// SSPI and MSPI wires //{

wire [31:0] w_SSPI_CON_WI  = w_ep02wire; // controls ... 
			// w_SSPI_CON_WI[0] enables SSPI control against USB 
			// w_SSPI_CON_WI[1] ...
wire [31:0] w_SSPI_FLAG_WO; 
	assign w_ep23wire = w_SSPI_FLAG_WO; //$$ ep22wire --> ep23wire
//

// HW reset signal : MEM, TEST_COUNTER, XADC, TIMESTAMP // SPIO, DAC, ADC, TRIG_IO,
wire w_HW_reset__ext;
wire w_HW_reset = w_SSPI_CON_WI[3] | w_HW_reset__ext | w_BRD_CON_WI[0] ; //$$

wire w_SSPI_TEST_mode_en; //$$ hw emulation for mother board master spi //$$ w_MTH_SPI_emulation__en ??

//$wire [31:0] w_SSPI_TEST_WI   = ep17wire; // test data for SSPI
//$wire [31:0] w_SSPI_TEST_WO; //$$ assign ep21wire = w_SSPI_TEST_WO; //$$ share with ep21wire or w_TEST_FLAG_WO
//wire [31:0] w_MSPI_CON_WI   = ep17wire; // w_SSPI_TEST_WI --> w_MSPI_CON_WI// test data for SSPI


//=================== TEST SUL071 ============= //
wire [31:0] w_MSPI_CON_WI   = (w_mcs_ep_wi_en)? w_port_wi_17_1 : w_ep17wire; //$$ MSPI frame data
wire [31:0] w_MSPI_EN_CS_WI = (w_mcs_ep_wi_en)? w_port_wi_16_1 : w_ep16wire; //$$ MSPI nCSX enable

//$$ alias SPI group selection
wire w_M0_SPI_CS_enable = w_MSPI_EN_CS_WI[16] | ((~w_MSPI_EN_CS_WI[17])&(~w_MSPI_EN_CS_WI[18]));
wire w_M1_SPI_CS_enable = w_MSPI_EN_CS_WI[17];
wire w_M2_SPI_CS_enable = w_MSPI_EN_CS_WI[18];


wire [31:0] w_MSPI_FLAG_WO; // w_TEST_FLAG_WO --> SSPI_TEST_WO --> MSPI_FLAG_WO
assign w_port_wo_24_1   = w_MSPI_FLAG_WO ;
assign       w_ep24wire = w_MSPI_FLAG_WO ; //$$ arm host


//wire [31:0] w_SSPI_TI   = ep42trig; assign ep42ck = sys_clk;
//wire [31:0] w_SSPI_TEST_TI   = ep42trig; assign ep42ck = base_sspi_clk;
//$$ w_SSPI_TEST_TI --> w_MSPI_TI 
//=================== TEST SUL071 ============= //
wire [31:0] w_MSPI_TI   = ( w_mcs_ep_ti_en)? w_port_ti_42_1 : w_ep42trig;



//wire [31:0] w_SSPI_TO      = 32'b0; assign ep62trig = w_SSPI_TO; assign ep62ck = sys_clk;
//wire [31:0] w_SSPI_TEST_TO; assign ep62trig = w_SSPI_TEST_TO; assign ep62ck = base_sspi_clk; // vs sys_clk
//$$ w_SSPI_TEST_TO --> w_MSPI_TO 
wire [31:0] w_MSPI_TO;
assign w_port_to_62_1   = ( w_mcs_ep_to_en)? w_MSPI_TO : 32'h0000_0000; 
assign       w_ep62trig = (!w_mcs_ep_to_en)? w_MSPI_TO : 32'h0000_0000; //$$ arm host

//
wire [31:0] w_SSPI_BD_STAT_WO           ;  // rev...
wire [31:0] w_SSPI_CNT_CS_M0_WO         ;  // rev...

//}




//// EEPROM wires //{
wire [31:0] w_MEM_WI      = ( w_mcs_ep_wi_en)? w_port_wi_13_1 : w_ep13wire;
wire [31:0] w_MEM_FDAT_WI = ( w_mcs_ep_wi_en)? w_port_wi_12_1 : w_ep12wire;
wire [31:0] w_MEM_TI      =                    w_port_ti_53_1 | w_ep53trig; 
wire [31:0] w_MEM_TO; 
assign w_port_to_73_1     = ( w_mcs_ep_to_en)? w_MEM_TO : 32'b0; 
assign       w_ep73trig   = (~w_mcs_ep_to_en)? w_MEM_TO : 32'b0; 
wire [31:0] w_MEM_PI      = ( w_mcs_ep_pi_en)? w_port_pi_93_1 : w_ep93pipe;
wire [31:0] w_MEM_PO; 
assign       w_epB3pipe   = w_MEM_PO; 
assign w_port_po_B3_1     = w_MEM_PO; 
wire w_MEM_PI_wr          =                         w_wr_93_1 | w_ep93wr; 
wire w_MEM_PO_rd          =                         w_rd_B3_1 | w_epB3rd; 

//}


//}



///TODO: //-------------------------------------------------------//

/* timestamp */ //{
// global time index in debugger based on 10MHz 

//sub_timestamp //{
sub_timestamp sub_timestamp_inst(
	.clk         (sys_clk),
	.reset_n     (reset_n),
	.o_timestamp (w_TIMESTAMP_WO),
	.valid       ()
);
//}

//}


/* TEST COUNTER */ //{

// wires //{
wire [7:0]  w_test; // moving pattern
wire [7:0]  count1;
wire        count1eq00;
wire        count1eq80;
wire        reset1;
wire        disable1;
wire [7:0]  count2;
wire        count2eqFF;
wire        reset2;
wire        up2;
wire        down2;
wire        autocount2;
//}

// assign //{

// Counter 1:
assign reset1     = w_TEST_CON_WI[0]; 
assign disable1   = w_TEST_CON_WI[1]; 
assign autocount2 = w_TEST_CON_WI[2]; 
//
assign w_TEST_OUT_WO[15:0]  = {count2[7:0], count1[7:0]}; 
assign w_TEST_OUT_WO[31:16] = 16'b0; 
// Counter 2:
assign reset2     = w_TEST_TI[0];
assign up2        = w_TEST_TI[1];
assign down2      = w_TEST_TI[2];
//
assign w_TEST_TO   = {15'b0, count2eqFF, 14'b0, count1eq80, count1eq00};

// LED drive //{

//// note: fpga module    uses high-Z output // 7..0 ... B17,B16,A16,B15,A15,A14,B13,A13
//// note: S3100-CPU-BASE uses high-Z output // 7..0 ... V19,V18,Y19,Y18,W20,W19,V20,U20

// xem7310_led:
//   1 in --> 0 out // tri_0, out_0
//   0 in --> Z out // tri_1, out_X
function [7:0] xem7310_led;
input [7:0] a;
integer i;
begin
	for(i=0; i<8; i=i+1) begin: u
		//xem7310_led[i] = (a[i]==1'b1) ? (1'b0) : (1'bz);
		xem7310_led[i] = (a[i]==1'b1) ? (1'b0) : (1'b1); // inverter
	end
end
endfunction
// 
//assign led = xem7310_led(w_test ^ count1);
//}

//}

// test_counter_wrapper //{
test_counter_wrapper  test_counter_wrapper_inst(
	.sys_clk (sys_clk),
	.reset_n (reset_n),
	//
	.o_test        (w_test),
	//
	.o_count1      (count1),
	//
	.o_count1eq00  (count1eq00),
	.o_count1eq80  (count1eq80),
	//
	.reset1        (reset1),
	.disable1      (disable1),
	//
	.o_count2      (count2),
	//
	.o_count2eqFF  (count2eqFF),
	//
	.reset2        (reset2    ),
	.up2           (up2       ),
	.down2         (down2     ),
	.autocount2    (autocount2)
	//             
);
//}

//}


/* XADC */ //{

// wires and end-points //{

wire [31:0] w_XADC_TEMP_WO; 
assign w_port_wo_3A_1   = w_XADC_TEMP_WO ;
assign       w_ep3Awire = w_XADC_TEMP_WO ;
//
wire [31:0] w_XADC_VOLT_WO; 
assign w_port_wo_3B_1   = w_XADC_VOLT_WO ;
assign       w_ep3Bwire = w_XADC_VOLT_WO ;

// XADC_DRP
wire [31:0] MEASURED_TEMP_MC;
wire [31:0] MEASURED_VCCINT_MV;
wire [31:0] MEASURED_VCCAUX_MV;
wire [31:0] MEASURED_VCCBRAM_MV;
//
wire [7:0] dbg_drp;
//}

// master_drp_ug480 //{
master_drp_ug480 master_drp_ug480_inst(
	.DCLK				(xadc_clk), // input DCLK, // Clock input for DRP
	.RESET				(~reset_n), // input RESET,
	.VP					(i_XADC_VP), // input VP, VN,// Dedicated and Hardwired Analog Input Pair
	.VN					(i_XADC_VN),
	.MEASURED_TEMP		(), // output reg [15:0] MEASURED_TEMP, MEASURED_VCCINT,
	.MEASURED_VCCINT	(),
	.MEASURED_VCCAUX	(), // output reg [15:0] MEASURED_VCCAUX, MEASURED_VCCBRAM,
	.MEASURED_VCCBRAM	(),
	// converted to decimal
	.MEASURED_TEMP_MC		(MEASURED_TEMP_MC), 
	.MEASURED_VCCINT_MV		(MEASURED_VCCINT_MV),
	.MEASURED_VCCAUX_MV		(MEASURED_VCCAUX_MV), 
	.MEASURED_VCCBRAM_MV	(MEASURED_VCCBRAM_MV),
	//
	.ALM_OUT	(), // output wire ALM_OUT,
	.CHANNEL	(), // output wire [4:0] CHANNEL,
	.OT			(), // output wire OT,
	.XADC_EOC	(), // output wire XADC_EOC,
	.XADC_EOS	(), // output wire XADC_EOS
	.debug_out	(dbg_drp)
);
//}

// assign //{
assign w_XADC_TEMP_WO = MEASURED_TEMP_MC;
//
assign w_XADC_VOLT_WO = MEASURED_VCCINT_MV;
//$$  assign w_XADC_VOLT_WO = 
//$$  	(count2[7:6]==2'b00)? MEASURED_VCCINT_MV  :
//$$  	(count2[7:6]==2'b01)? MEASURED_VCCAUX_MV  :
//$$  	(count2[7:6]==2'b10)? MEASURED_VCCBRAM_MV :
//$$  		32'b0;
//}

//}


///TODO: //-------------------------------------------------------//





///TODO: //-------------------------------------------------------//


/* TODO: EEPROM */ //{
// support 11AA160T-I/TT 
// io signal, open-drain
// note that 10K ohm pull up is located on board.
// net in sch : SCIO_0              in S3100-CPU-BASE
// pin in fpga: io_B15_L11P_SRCC    in S3100-CPU-BASE

//$$ S3100 vs TXEM7310
//// note: fpga module in PGU    uses io_B34_L5N       // Y1
//// note: S3100-CPU-BASE SCIO_0 uses io_B15_L11P_SRCC // J20


// fifo read clock //{
wire c_eeprom_fifo_clk; // clock mux between lan and usb/slave-spi end-points

//assign c_eeprom_fifo_clk = (w_sel__H_LAN_for_EEPROM_fifo == 0)? okClk : mcs_eeprom_fifo_clk ; //$$ remove BUFGMUX
//assign c_eeprom_fifo_clk = (w_mcs_ep_pi_en)? mcs_eeprom_fifo_clk : epClk;
assign c_eeprom_fifo_clk = (w_mcs_ep_pi_en)? w_ck_pipe : w_ck_core;

//}


// module //{

wire w_MEM_rst;
wire w_MEM_fifo_rst;
wire w_MEM_valid;
//
wire w_trig_frame   ;
wire w_done_frame   ;
wire w_done_frame_TO;
//
wire [7:0] w_frame_data_CMD    ;
wire [7:0] w_frame_data_ADH    ;
wire [7:0] w_frame_data_ADL    ;
wire [7:0] w_frame_data_STA_in ;
wire [7:0] w_frame_data_STA_out;
//
wire [11:0] w_num_bytes_DAT    ;
wire        w_con_disable_SBP;
//
wire [7:0] w_frame_data_DAT_wr   ;
wire [7:0] w_frame_data_DAT_rd   ;
wire       w_frame_data_DAT_wr_en;
wire       w_frame_data_DAT_rd_en;
//
wire w_SCIO_DI; // io port from module
wire w_SCIO_DO; // io port from module
wire w_SCIO_OE; // io port from module

//
control_eeprom__11AA160T  control_eeprom__11AA160T_inst(
	//
	.clk     (sys_clk                ), //	input  wire // 10MHz
	.reset_n (reset_n & (~w_MEM_rst) & (~w_HW_reset)), //	input  wire // TI
	
	// controls //{
	.i_trig_frame     (w_trig_frame   ), //	input  wire                    // TI
	.o_done_frame     (w_done_frame   ), //	output wire                    // TO
	.o_done_frame_TO  (w_done_frame_TO), //	output wire  // trig out @ clk // TO
	//	
	.i_en_SBP         (~w_con_disable_SBP  ), //	input  wire  // enable SBP (stand-by pulse) // WI
	//
	.i_frame_data_SHD (8'h55           ), //	input  wire [7:0]  // fixed
	.i_frame_data_DVA (8'hA0           ), //	input  wire [7:0]  // fixed
	.i_frame_data_CMD (w_frame_data_CMD    ), //	input  wire [7:0]  // WI
	.i_frame_data_ADH (w_frame_data_ADH    ), //	input  wire [7:0]  // WI
	.i_frame_data_ADL (w_frame_data_ADL    ), //	input  wire [7:0]  // WI
	.i_frame_data_STA (w_frame_data_STA_in ), //	input  wire [7:0]  // WI
	.o_frame_data_STA (w_frame_data_STA_out), //	output wire [7:0]  // TO
	//	
	.i_num_bytes_DAT  (w_num_bytes_DAT     ), //	input  wire [11:0] // WI
	//}
	
	// FIFO/PIPE interface //{
	.i_reset_fifo             (w_MEM_fifo_rst), //	input  wire    // TI
	//
	.i_frame_data_DAT         (w_frame_data_DAT_wr   ), //	input  wire [7:0] // PI
	.o_frame_data_DAT         (w_frame_data_DAT_rd   ), //	output wire [7:0] // PO
	//
	.i_frame_data_DAT_wr_en   (w_frame_data_DAT_wr_en), // input wire // control for i_frame_data_DAT
	.i_frame_data_DAT_wr_clk  (c_eeprom_fifo_clk     ), // input wire // control for i_frame_data_DAT
	.i_frame_data_DAT_rd_en   (w_frame_data_DAT_rd_en), // input wire // control for o_frame_data_DAT	
	.i_frame_data_DAT_rd_clk  (c_eeprom_fifo_clk     ), // input wire // control for o_frame_data_DAT	
	//}
	
	// IO ports //{
	.i_SCIO_DI        (w_SCIO_DI), // input  wire 
	.o_SCIO_DO        (w_SCIO_DO), // output wire 
	.o_SCIO_OE        (w_SCIO_OE), // output wire 
	//}

	.valid            (w_MEM_valid)//	output wire 
);


//}

// assignment //{

//// MEM endpoints //{
assign w_num_bytes_DAT               = w_MEM_WI[11:0]; // 12-bit 
assign w_con_disable_SBP             = w_MEM_WI[15]  ; // 1-bit

assign w_frame_data_CMD              = w_MEM_FDAT_WI[ 7: 0]; // 8-bit
assign w_frame_data_STA_in           = w_MEM_FDAT_WI[15: 8]; // 8-bit
assign w_frame_data_ADL              = w_MEM_FDAT_WI[23:16]; // 8-bit
assign w_frame_data_ADH              = w_MEM_FDAT_WI[31:24]; // 8-bit

assign w_MEM_rst      = w_MEM_TI[0];
assign w_MEM_fifo_rst = w_MEM_TI[1];
assign w_trig_frame   = w_MEM_TI[2];

assign w_MEM_TO[0]     = w_MEM_valid    ;
assign w_MEM_TO[1]     = w_done_frame   ;
assign w_MEM_TO[2]     = w_done_frame_TO;
assign w_MEM_TO[ 7: 3] =  5'b0;
assign w_MEM_TO[15: 8] = w_frame_data_STA_out; 
assign w_MEM_TO[31:16] = 16'b0;

assign w_frame_data_DAT_wr    = w_MEM_PI[7:0]; // 8-bit
assign w_frame_data_DAT_wr_en = w_MEM_PI_wr;

assign w_MEM_PO[7:0]          = w_frame_data_DAT_rd; // 8-bit
assign w_MEM_PO[31:8]         = {24{w_frame_data_DAT_rd[7]}}; // rev signed expansion for compatibility
assign w_frame_data_DAT_rd_en = w_MEM_PO_rd;
//}

//// port mux with TP // removed
//  assign w_SCIO_DI   = ( w_sel__H_EEPROM_on_TP)?   TP_in[2] : MEM_SIO_in ; // switching
//  //                     
//  assign TP_out[2]   = ( w_sel__H_EEPROM_on_TP)?  w_SCIO_DO : 1'b0 ; // test TP 
//  assign TP_tri[2]   = ( w_sel__H_EEPROM_on_TP)? ~w_SCIO_OE : 1'b1 ; // test TP 
//  //
//  assign TP_out[0]   = ( w_sel__H_EEPROM_on_TP)? 1'b1 : 1'b0 ; // for test power (3.3V) on signal line
//  assign TP_out[1]   = ( w_sel__H_EEPROM_on_TP)? 1'b0 : 1'b0 ; // for test power (GND)  on signal line
//  assign TP_tri[0]   = ( w_sel__H_EEPROM_on_TP)? 1'b0 : 1'b1 ; // for test power on signal line
//  assign TP_tri[1]   = ( w_sel__H_EEPROM_on_TP)? 1'b0 : 1'b1 ; // for test power on signal line
//  //                     
//  assign MEM_SIO_out = (~w_sel__H_EEPROM_on_TP)?  w_SCIO_DO : 1'b0 ; // dedicated port
//  assign MEM_SIO_tri = (~w_sel__H_EEPROM_on_TP)? ~w_SCIO_OE : 1'b1 ; // dedicated port


//// mapping io via module

//// SCIO_0
assign                SCIO_0_tri  = ~w_SCIO_OE ;
assign                SCIO_0_out  =  w_SCIO_DO ;
assign w_SCIO_DI   =  SCIO_0_in ; 

//// SCIO_1 // reserved
assign  SCIO_1_tri = 1'b1; // high-Z
assign  SCIO_1_out = 1'b0; 



//}


//}


///TODO: //-------------------------------------------------------//

/* TODO: Master_SPI emulation for Slave_SPI  or  MSPI */ //{


// module //{

//// Master SPI endpoints
//
// MSPI_TI : ep42trig
//   bit[0] = reset_trig 
//   bit[1] = init_trig
//   bit[2] = frame_trig
//
// MSPI_TO : ep62trig
//   bit[0] = reset_done
//   bit[1] = init_done
//   bit[2] = frame_done
//
// MSPI_CON_WI : ep17wire
//  bit[31:26] = data_C // control[5:0]
//  bit[25:16] = data_A // address[9:0]
//  bit[15: 0] = data_D // MOSI data[15:0]
//
// MSPI_EN_CS_WI : ep16wire
//  bit[0 ] = enable SPI_nCS0  
//  bit[1 ] = enable SPI_nCS1  
//  bit[2 ] = enable SPI_nCS2  
//  bit[3 ] = enable SPI_nCS3  
//  bit[4 ] = enable SPI_nCS4  
//  bit[5 ] = enable SPI_nCS5  
//  bit[6 ] = enable SPI_nCS6  
//  bit[7 ] = enable SPI_nCS7  
//  bit[8 ] = enable SPI_nCS8  
//  bit[9 ] = enable SPI_nCS9  
//  bit[10] = enable SPI_nCS10 
//  bit[11] = enable SPI_nCS11 
//  bit[12] = enable SPI_nCS12 
//
// MSPI_FLAG_WO : ep24wire
//  bit[23]   = TEST_mode_en
//  bit[15:0] = data_B // MISO data[15:0]

wire w_SSPI_TEST_trig_reset = w_MSPI_TI[0];
assign w_MSPI_TO[0]    = w_SSPI_TEST_trig_reset;
//
wire  w_SSPI_TEST_trig_init = w_MSPI_TI[1];
wire  w_SSPI_TEST_done_init ;
assign w_SSPI_TEST_mode_en = w_SSPI_TEST_done_init;
assign w_MSPI_TO[1]   = w_SSPI_TEST_done_init;
//
wire  w_SSPI_TEST_trig_frame = w_MSPI_TI[2];
wire  w_SSPI_TEST_done_frame;
assign w_MSPI_TO[2]   = w_SSPI_TEST_done_frame;
//
assign w_MSPI_TO[31:3] = 29'b0;

//
wire  [ 5:0] w_SSPI_frame_data_C = w_MSPI_CON_WI[31:26]; // w_SSPI_TEST_WI --> w_MSPI_CON_WI
wire  [ 9:0] w_SSPI_frame_data_A = w_MSPI_CON_WI[25:16]; // w_SSPI_TEST_WI --> w_MSPI_CON_WI
wire  [15:0] w_SSPI_frame_data_D = w_MSPI_CON_WI[15: 0]; // w_SSPI_TEST_WI --> w_MSPI_CON_WI
//
wire  [15:0] w_SSPI_frame_data_B;
wire  [15:0] w_SSPI_frame_data_E;
assign w_MSPI_FLAG_WO[31:16] = w_SSPI_frame_data_E[15:0];
assign w_MSPI_FLAG_WO[15: 0] = w_SSPI_frame_data_B[15:0]; //$$ w_SSPI_TEST_WO --> w_MSPI_FLAG_WO

(* keep = "true" *) wire  w_SSPI_TEST_SS_B   ;
(* keep = "true" *) wire  w_SSPI_TEST_MCLK   ;
(* keep = "true" *) wire  w_SSPI_TEST_SCLK   ;
(* keep = "true" *) wire  w_SSPI_TEST_MOSI   ;
(* keep = "true" *) wire  w_SSPI_TEST_MISO   ;
(* keep = "true" *) wire  w_SSPI_TEST_MISO_EN;

assign  w_SSPI_TEST_MISO_EN = w_SSPI_TEST_mode_en ; 
//$$assign  w_SSPI_TEST_SCLK    = M0_SPI_RX_CLK       ; //$$ must come from SSPI in test.
//$$assign  w_SSPI_TEST_MISO    = M0_SPI_MISO         ; //$$ must come from SSPI in test.



//
master_spi_mth_brd  master_spi_mth_brd__inst(
	.clk     (base_sspi_clk), // 104MHz
	.reset_n (reset_n & (~w_SSPI_TEST_trig_reset)),
	
	// control 
	.i_trig_init    (w_SSPI_TEST_trig_init ), // level sampling inside based on clk
	.o_done_init    (w_SSPI_TEST_done_init ), // to be used for monitoring test mode 
	.i_trig_frame   (w_SSPI_TEST_trig_frame), // rise-edge detection inside based on clk
	.o_done_frame   (w_SSPI_TEST_done_frame), // level output

	// frame data 
	.i_frame_data_C (w_SSPI_frame_data_C), // [ 5:0] // control  data on MOSI
	.i_frame_data_A (w_SSPI_frame_data_A), // [ 9:0] // address  data on MOSI
	.i_frame_data_D (w_SSPI_frame_data_D), // [15:0] // register data on MOSI
	//
	.o_frame_data_B (w_SSPI_frame_data_B), // [15:0] // readback data on MISO, low  16 bits
	.o_frame_data_E (w_SSPI_frame_data_E), // [15:0] // readback data on MISO, high 16 bits
	
	// IO 
	.o_SS_B    (w_SSPI_TEST_SS_B   ),
	.o_MCLK    (w_SSPI_TEST_MCLK   ), // sclk master out 
	.i_SCLK    (w_SSPI_TEST_SCLK   ), // sclk slave in
	.o_MOSI    (w_SSPI_TEST_MOSI   ),
	.i_MISO    (w_SSPI_TEST_MISO   ),
	.i_MISO_EN (w_SSPI_TEST_MISO_EN),
	
	.valid  ()
); 
//}

//}


///TODO: //-------------------------------------------------------//

/* TODO: Slave_SPI from Mother board  or  SSPI */ //{


// modules //{
(* keep = "true" *) wire w_M0_SPI_CS_B_BUF;
(* keep = "true" *) wire w_M0_SPI_CLK     ;
(* keep = "true" *) wire w_M0_SPI_MOSI    ;
(* keep = "true" *) wire w_M0_SPI_MISO    ;
(* keep = "true" *) wire w_M0_SPI_MISO_EN ;

//$$ for S3100 test
assign w_M0_SPI_CS_B_BUF = w_SSPI_TEST_SS_B;
assign w_M0_SPI_CLK      = w_SSPI_TEST_MCLK;
assign w_M0_SPI_MOSI     = w_SSPI_TEST_MOSI;

//$$assign  w_SSPI_TEST_SCLK    = w_M0_SPI_CLK       ; //$$ must come from SSPI in test.
//$$assign  w_SSPI_TEST_MISO    = w_M0_SPI_MISO      ; //$$ must come from SSPI in test.


wire [15:0] w_M0_cnt_sspi_cs;

//// serial address:
wire [31:0] w_M0_port_wi_sadrs_h008; // SSPI_CON_WI			0x008	wi02
//
wire [31:0] w_M0_port_wo_sadrs_h080 = w_F_IMAGE_ID_WO; //  FPGA_IMAGE_ID_WO  0x080	wo20
wire [31:0] w_M0_port_wo_sadrs_h088 = w_TIMESTAMP_WO    ; //  TIMESTAMP_WO      0x088	wo22
wire [31:0] w_M0_port_wo_sadrs_h08C = w_SSPI_FLAG_WO    ; //  SSPI_FLAG_WO      0x08C	wo23
wire [31:0] w_M0_port_wo_sadrs_h090 = w_MSPI_FLAG_WO    ; //  MSPI_FLAG_WO      0x090	wo24
//
wire [31:0] w_M0_port_wo_sadrs_h380 = 32'h33AA_CC55     ; // SSPI_TEST_OUT		0x380	NA  // known pattern
wire [31:0] w_M0_port_wo_sadrs_h384 = w_SSPI_BD_STAT_WO           ;
wire [31:0] w_M0_port_wo_sadrs_h388 = w_SSPI_CNT_CS_M0_WO         ;
//
wire        w_M0_loopback_en           = (~w_SSPI_CON_WI[0])? w_M0_port_wi_sadrs_h008[24]    : 
														   w_SSPI_CON_WI[24]              ;
wire        w_M0_MISO_one_bit_ahead_en = (~w_SSPI_CON_WI[0])? w_M0_port_wi_sadrs_h008[25]    : 
														   w_SSPI_CON_WI[25]              ;
wire [2:0]  w_M0_slack_count_MISO      = (~w_SSPI_CON_WI[0])? w_M0_port_wi_sadrs_h008[30:28] :
														   w_SSPI_CON_WI[30:28]           ;


wire [7:0] w_board_status = 8'b0; // test


//
slave_spi_mth_brd  slave_spi_mth_brd__M0_inst(
	.clk     (base_sspi_clk), // base clock 72MHz or 104MHz
	.reset_n (reset_n),
	
	//// slave SPI pins:
	.i_SPI_CS_B      (w_M0_SPI_CS_B_BUF),
	.i_SPI_CLK       (w_M0_SPI_CLK     ),
	.i_SPI_MOSI      (w_M0_SPI_MOSI    ),
	.o_SPI_MISO      (w_M0_SPI_MISO    ),
	.o_SPI_MISO_EN   (w_M0_SPI_MISO_EN ), // MISO buffer control
	
	.o_cnt_sspi_cs   (w_M0_cnt_sspi_cs ), // [15:0] //$$
	
	//// test register interface
	
	// wi
	.o_port_wi_sadrs_h008    (w_M0_port_wi_sadrs_h008), // [31:0] // SSPI_CON_WI		0x008	wi02
	
	// wo
	.i_port_wo_sadrs_h080    (w_M0_port_wo_sadrs_h080),
	.i_port_wo_sadrs_h088    (w_M0_port_wo_sadrs_h088),
	.i_port_wo_sadrs_h08C    (w_M0_port_wo_sadrs_h08C),
	.i_port_wo_sadrs_h090    (w_M0_port_wo_sadrs_h090),
	//
	.i_port_wo_sadrs_h380    (w_M0_port_wo_sadrs_h380), // [31:0] // adrs h383~h380	
	.i_port_wo_sadrs_h384    (w_M0_port_wo_sadrs_h384), // [31:0] // SSPI_BD_STAT_WO           
	.i_port_wo_sadrs_h388    (w_M0_port_wo_sadrs_h388), // [31:0] // SSPI_CNT_CS_M0_WO         
	
	// ti

	// to

	// pi
	
	// po
	
	//// loopback mode control 
	.i_loopback_en           (w_M0_loopback_en),

	//// timing control 
	.i_slack_count_MISO      (w_M0_slack_count_MISO), // [2:0] // '0' for MISO on SCLK falling edge; 'n' for earlier location
	.i_MISO_one_bit_ahead_en (w_M0_MISO_one_bit_ahead_en), // '1' for MISO one bit ahead mode.  

	.i_board_id      (w_slot_id    ), // [3:0] // slot ID
	.i_board_status  (w_board_status), // [7:0] // board status

	.valid    () 
);




//}

// assignments //{




// miso control M0
assign w_M0_loopback_en        = (~w_SSPI_CON_WI[0])? w_M0_port_wi_sadrs_h008[24]    : 
												   w_SSPI_CON_WI[24]              ;
assign w_M0_slack_count_MISO   = (~w_SSPI_CON_WI[0])? w_M0_port_wi_sadrs_h008[30:28] :
												   w_SSPI_CON_WI[30:28]           ;

// HW reset control 
assign w_HW_reset__ext        = w_M0_port_wi_sadrs_h008[3]; //$$


// flag assignment 
assign w_SSPI_FLAG_WO[0]     = w_SSPI_CON_WI[0]; // enables SSPI control from MCS or USB 
assign w_SSPI_FLAG_WO[2]     = 1'b0; 
assign w_SSPI_FLAG_WO[3]     = w_HW_reset; //$$ HW reset status
assign w_SSPI_FLAG_WO[7:4]   = w_slot_id[3:0]     ; // show board slot id 
assign w_SSPI_FLAG_WO[15:8]  = w_board_status[7:0]; // show board status
assign w_SSPI_FLAG_WO[23:16] = 8'b0;
assign w_SSPI_FLAG_WO[27:24] = {w_M0_slack_count_MISO[2:0], w_M0_loopback_en}; // miso control
assign w_SSPI_FLAG_WO[31:28] = 4'b0; // {w_M1_slack_count_MISO[2:0], w_M1_loopback_en}; // miso control

//w_SSPI_BD_STAT_WO           
assign w_SSPI_BD_STAT_WO[7:0]  = w_board_status[7:0];
assign w_SSPI_BD_STAT_WO[11:8] = w_slot_id;
assign w_SSPI_BD_STAT_WO[15:12] = 4'b0;
assign w_SSPI_BD_STAT_WO[31:16] = w_board_id;

//w_SSPI_CNT_CS_M0_WO         
assign w_SSPI_CNT_CS_M0_WO[15:0]  = w_M0_cnt_sspi_cs; //$$ count the falling edge of i_SPI_CS_B
assign w_SSPI_CNT_CS_M0_WO[31:16] = 16'b0;


//}


//}


/* TODO: Mux MTH ... MISO and SCLK  */ //{

//$$ note ... mux signals according to w_MSPI_EN_CS_WI[*]
//$$ slave SPI emulation is activated when w_MSPI_EN_CS_WI == 0.
//$$ S3100-PGU is on M2

assign  FPGA_M0_SPI_TX_EN   = w_SSPI_TEST_mode_en ;
assign       M0_SPI_TX_CLK  = w_SSPI_TEST_MCLK    ;
assign       M0_SPI_MOSI    = w_SSPI_TEST_MOSI    ;
assign  FPGA_M0_SPI_nCS0_   = (w_M0_SPI_CS_enable & w_MSPI_EN_CS_WI[0 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M0_SPI_nCS1_   = (w_M0_SPI_CS_enable & w_MSPI_EN_CS_WI[1 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M0_SPI_nCS2_   = (w_M0_SPI_CS_enable & w_MSPI_EN_CS_WI[2 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M0_SPI_nCS3_   = (w_M0_SPI_CS_enable & w_MSPI_EN_CS_WI[3 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M0_SPI_nCS4_   = (w_M0_SPI_CS_enable & w_MSPI_EN_CS_WI[4 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M0_SPI_nCS5_   = (w_M0_SPI_CS_enable & w_MSPI_EN_CS_WI[5 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M0_SPI_nCS6_   = (w_M0_SPI_CS_enable & w_MSPI_EN_CS_WI[6 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M0_SPI_nCS7_   = (w_M0_SPI_CS_enable & w_MSPI_EN_CS_WI[7 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M0_SPI_nCS8_   = (w_M0_SPI_CS_enable & w_MSPI_EN_CS_WI[8 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M0_SPI_nCS9_   = (w_M0_SPI_CS_enable & w_MSPI_EN_CS_WI[9 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M0_SPI_nCS10   = (w_M0_SPI_CS_enable & w_MSPI_EN_CS_WI[10])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M0_SPI_nCS11   = (w_M0_SPI_CS_enable & w_MSPI_EN_CS_WI[11])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M0_SPI_nCS12   = (w_M0_SPI_CS_enable & w_MSPI_EN_CS_WI[12])? w_SSPI_TEST_SS_B : 1'b1 ;

assign  FPGA_M1_SPI_TX_EN   = w_SSPI_TEST_mode_en ;
assign       M1_SPI_TX_CLK  = w_SSPI_TEST_MCLK    ;
assign       M1_SPI_MOSI    = w_SSPI_TEST_MOSI    ;
assign  FPGA_M1_SPI_nCS0_   = (w_M1_SPI_CS_enable & w_MSPI_EN_CS_WI[0 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M1_SPI_nCS1_   = (w_M1_SPI_CS_enable & w_MSPI_EN_CS_WI[1 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M1_SPI_nCS2_   = (w_M1_SPI_CS_enable & w_MSPI_EN_CS_WI[2 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M1_SPI_nCS3_   = (w_M1_SPI_CS_enable & w_MSPI_EN_CS_WI[3 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M1_SPI_nCS4_   = (w_M1_SPI_CS_enable & w_MSPI_EN_CS_WI[4 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M1_SPI_nCS5_   = (w_M1_SPI_CS_enable & w_MSPI_EN_CS_WI[5 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M1_SPI_nCS6_   = (w_M1_SPI_CS_enable & w_MSPI_EN_CS_WI[6 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M1_SPI_nCS7_   = (w_M1_SPI_CS_enable & w_MSPI_EN_CS_WI[7 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M1_SPI_nCS8_   = (w_M1_SPI_CS_enable & w_MSPI_EN_CS_WI[8 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M1_SPI_nCS9_   = (w_M1_SPI_CS_enable & w_MSPI_EN_CS_WI[9 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M1_SPI_nCS10   = (w_M1_SPI_CS_enable & w_MSPI_EN_CS_WI[10])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M1_SPI_nCS11   = (w_M1_SPI_CS_enable & w_MSPI_EN_CS_WI[11])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M1_SPI_nCS12   = (w_M1_SPI_CS_enable & w_MSPI_EN_CS_WI[12])? w_SSPI_TEST_SS_B : 1'b1 ;

assign  FPGA_M2_SPI_TX_EN   = w_SSPI_TEST_mode_en ;
assign       M2_SPI_TX_CLK  = w_SSPI_TEST_MCLK    ;
assign       M2_SPI_MOSI    = w_SSPI_TEST_MOSI    ;
assign  FPGA_M2_SPI_nCS0_   = (w_M2_SPI_CS_enable & w_MSPI_EN_CS_WI[0 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M2_SPI_nCS1_   = (w_M2_SPI_CS_enable & w_MSPI_EN_CS_WI[1 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M2_SPI_nCS2_   = (w_M2_SPI_CS_enable & w_MSPI_EN_CS_WI[2 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M2_SPI_nCS3_   = (w_M2_SPI_CS_enable & w_MSPI_EN_CS_WI[3 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M2_SPI_nCS4_   = (w_M2_SPI_CS_enable & w_MSPI_EN_CS_WI[4 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M2_SPI_nCS5_   = (w_M2_SPI_CS_enable & w_MSPI_EN_CS_WI[5 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M2_SPI_nCS6_   = (w_M2_SPI_CS_enable & w_MSPI_EN_CS_WI[6 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M2_SPI_nCS7_   = (w_M2_SPI_CS_enable & w_MSPI_EN_CS_WI[7 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M2_SPI_nCS8_   = (w_M2_SPI_CS_enable & w_MSPI_EN_CS_WI[8 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M2_SPI_nCS9_   = (w_M2_SPI_CS_enable & w_MSPI_EN_CS_WI[9 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M2_SPI_nCS10   = (w_M2_SPI_CS_enable & w_MSPI_EN_CS_WI[10])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M2_SPI_nCS11   = (w_M2_SPI_CS_enable & w_MSPI_EN_CS_WI[11])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M2_SPI_nCS12   = (w_M2_SPI_CS_enable & w_MSPI_EN_CS_WI[12])? w_SSPI_TEST_SS_B : 1'b1 ;


assign  w_SSPI_TEST_SCLK    = (w_MSPI_EN_CS_WI==0)? w_M0_SPI_CLK  :
							  (w_M0_SPI_CS_enable)? M0_SPI_RX_CLK :
							  (w_M1_SPI_CS_enable)? M1_SPI_RX_CLK : 
							  (w_M2_SPI_CS_enable)? M2_SPI_RX_CLK :
													          1'b0; 
assign  w_SSPI_TEST_MISO    = (w_MSPI_EN_CS_WI==0)? w_M0_SPI_MISO :
							  (w_M0_SPI_CS_enable)? M0_SPI_MISO   : 
							  (w_M1_SPI_CS_enable)? M1_SPI_MISO   : 
							  (w_M2_SPI_CS_enable)? M2_SPI_MISO   :
													          1'b0; 


//}


///TODO: //-------------------------------------------------------//


///TODO: //-------------------------------------------------------//


/* TODO: M7 Core Board Address Decoder */ //{

//// address, data, control

//$$  wire [25:20] w_BA25_20; //{
//$$  assign  w_BA25_20[25] = BA25;
//$$  assign  w_BA25_20[24] = BA24;
//$$  assign  w_BA25_20[23] = BA23;
//$$  assign  w_BA25_20[22] = BA22;
//$$  assign  w_BA25_20[21] = BA21;
//$$  assign  w_BA25_20[20] = BA20;
//$$  //}
//$$  
//$$  wire [19:18] w_BA19_18; //{
//$$  assign  w_BA19_18[19] = BA19;
//$$  assign  w_BA19_18[18] = BA18;
//$$  //}
//$$  
//$$  wire [ 7: 2] w_BA7_2; //{
//$$  assign  w_BA7_2[ 7] = BA7;
//$$  assign  w_BA7_2[ 6] = BA6;
//$$  assign  w_BA7_2[ 5] = BA5;
//$$  assign  w_BA7_2[ 4] = BA4;
//$$  assign  w_BA7_2[ 3] = BA3;
//$$  assign  w_BA7_2[ 2] = BA2;
//$$  //}

wire [31:0] w_BD_out; //{
assign BD0__out = w_BD_out[0]  ;
assign BD1__out = w_BD_out[1]  ;
assign BD2__out = w_BD_out[2]  ;
assign BD3__out = w_BD_out[3]  ;
assign BD4__out = w_BD_out[4]  ;
assign BD5__out = w_BD_out[5]  ;
assign BD6__out = w_BD_out[6]  ;
assign BD7__out = w_BD_out[7]  ;
assign BD8__out = w_BD_out[8]  ;
assign BD9__out = w_BD_out[9]  ;
assign BD10_out = w_BD_out[10] ;
assign BD11_out = w_BD_out[11] ;
assign BD12_out = w_BD_out[12] ;
assign BD13_out = w_BD_out[13] ;
assign BD14_out = w_BD_out[14] ;
assign BD15_out = w_BD_out[15] ;

assign BD16_out = w_BD_out[16] ;
assign BD17_out = w_BD_out[17] ;
assign BD18_out = w_BD_out[18] ;
assign BD19_out = w_BD_out[19] ;
assign BD20_out = w_BD_out[20] ;
assign BD21_out = w_BD_out[21] ;
assign BD22_out = w_BD_out[22] ;
assign BD23_out = w_BD_out[23] ;
assign BD24_out = w_BD_out[24] ;
assign BD25_out = w_BD_out[25] ;
assign BD26_out = w_BD_out[26] ;
assign BD27_out = w_BD_out[27] ;
assign BD28_out = w_BD_out[28] ;
assign BD29_out = w_BD_out[29] ;
assign BD30_out = w_BD_out[30] ;
assign BD31_out = w_BD_out[31] ;
//}

// note: T = '1' ==> 'Z' (INPUT)
wire [31:0] w_BD_tri; //{
assign  BD31_tri = w_BD_tri[31];
assign  BD30_tri = w_BD_tri[30];
assign  BD29_tri = w_BD_tri[29];
assign  BD28_tri = w_BD_tri[28];
assign  BD27_tri = w_BD_tri[27];
assign  BD26_tri = w_BD_tri[26];
assign  BD25_tri = w_BD_tri[25];
assign  BD24_tri = w_BD_tri[24];
assign  BD23_tri = w_BD_tri[23];
assign  BD22_tri = w_BD_tri[22];
assign  BD21_tri = w_BD_tri[21];
assign  BD20_tri = w_BD_tri[20];
assign  BD19_tri = w_BD_tri[19];
assign  BD18_tri = w_BD_tri[18];
assign  BD17_tri = w_BD_tri[17];
assign  BD16_tri = w_BD_tri[16];

assign  BD15_tri = w_BD_tri[15];
assign  BD14_tri = w_BD_tri[14];
assign  BD13_tri = w_BD_tri[13];
assign  BD12_tri = w_BD_tri[12];
assign  BD11_tri = w_BD_tri[11];
assign  BD10_tri = w_BD_tri[10];
assign  BD9__tri = w_BD_tri[ 9];
assign  BD8__tri = w_BD_tri[ 8];
assign  BD7__tri = w_BD_tri[ 7];
assign  BD6__tri = w_BD_tri[ 6];
assign  BD5__tri = w_BD_tri[ 5];
assign  BD4__tri = w_BD_tri[ 4];
assign  BD3__tri = w_BD_tri[ 3];
assign  BD2__tri = w_BD_tri[ 2];
assign  BD1__tri = w_BD_tri[ 1];
assign  BD0__tri = w_BD_tri[ 0];
//}

wire [31:0] w_BD_in; //{
assign  w_BD_in[31] = BD31_in;
assign  w_BD_in[30] = BD30_in;
assign  w_BD_in[29] = BD29_in;
assign  w_BD_in[28] = BD28_in;
assign  w_BD_in[27] = BD27_in;
assign  w_BD_in[26] = BD26_in;
assign  w_BD_in[25] = BD25_in;
assign  w_BD_in[24] = BD24_in;
assign  w_BD_in[23] = BD23_in;
assign  w_BD_in[22] = BD22_in;
assign  w_BD_in[21] = BD21_in;
assign  w_BD_in[20] = BD20_in;
assign  w_BD_in[19] = BD19_in;
assign  w_BD_in[18] = BD18_in;
assign  w_BD_in[17] = BD17_in;
assign  w_BD_in[16] = BD16_in;

assign  w_BD_in[15] = BD15_in;
assign  w_BD_in[14] = BD14_in;
assign  w_BD_in[13] = BD13_in;
assign  w_BD_in[12] = BD12_in;
assign  w_BD_in[11] = BD11_in;
assign  w_BD_in[10] = BD10_in;
assign  w_BD_in[ 9] = BD9__in;
assign  w_BD_in[ 8] = BD8__in;
assign  w_BD_in[ 7] = BD7__in;
assign  w_BD_in[ 6] = BD6__in;
assign  w_BD_in[ 5] = BD5__in;
assign  w_BD_in[ 4] = BD4__in;
assign  w_BD_in[ 3] = BD3__in;
assign  w_BD_in[ 2] = BD2__in;
assign  w_BD_in[ 1] = BD1__in;
assign  w_BD_in[ 0] = BD0__in;
//}

wire w_nBNE1; wire w_nBNE2; wire w_nBNE3; wire w_nBNE4; //{
assign  w_nBNE1 = nBNE1;
assign  w_nBNE2 = nBNE2;
assign  w_nBNE3 = nBNE3;
assign  w_nBNE4 = nBNE4;
//}

wire w_nBOE; wire w_nBWE; //{
assign  w_nBOE = nBOE;
assign  w_nBWE = nBWE;
//}


//// arm core interface wrapper

(* keep = "true" *) wire          w_FMC_NCE = nBNE1;
(* keep = "true" *) wire [31 : 0] w_FMC_ADD ;
(* keep = "true" *) wire          w_FMC_NOE = nBOE;
(* keep = "true" *) wire [15 : 0] w_FMC_DRD ;
(* keep = "true" *) wire [15 : 0] w_FMC_DRD_TRI ;
(* keep = "true" *) wire          w_FMC_NWE = nBWE;
(* keep = "true" *) wire [15 : 0] w_FMC_DWR = w_BD_in;

assign w_FMC_ADD [31:26] = 6'b0;
assign w_FMC_ADD [25:18] = {BA25, BA24, BA23, BA22, BA21, BA20, BA19, BA18};
assign w_FMC_ADD [ 7: 2] = {BA7, BA6, BA5, BA4, BA3, BA2};
assign w_FMC_ADD [ 1: 0] = 2'b0;
//
assign w_BD_out[31:16] = 16'h0000;
assign w_BD_out[15: 0] = w_FMC_DRD;
assign w_BD_tri[31:16] = 16'hFFFF;
assign w_BD_tri[15: 0] = w_FMC_DRD_TRI;


core_endpoint_wrapper  core_endpoint_wrapper__inst (
	
	// clock and reset //{
	.clk      (sys_clk  ),
	.reset_n  (reset_n  ),
	.host_clk (host_clk ), // monitoring async bus signals
	//}
	
	// IO bus interface // async for arm io
	.i_FMC_NCE  ( w_FMC_NCE ),  // input  wire          // FMC_NCE
	.i_FMC_ADD  ( w_FMC_ADD ),  // input  wire [31 : 0] // FMC_ADD
	.i_FMC_NOE  ( w_FMC_NOE ),  // input  wire          // FMC_NOE
	.o_FMC_DRD  ( w_FMC_DRD ),  // output wire [15 : 0] // FMC_DRD
	.i_FMC_NWE  ( w_FMC_NWE ),  // input  wire          // FMC_NWE
	.i_FMC_DWR  ( w_FMC_DWR ),  // input  wire [15 : 0] // FMC_DWR
	
	// IO buffer control
	.o_FMC_DRD_TRI ( w_FMC_DRD_TRI ), // output wire [15 : 0]
	
	// end-points
	
	//// end-point address offset between high and low 16 bits //{
	.ep_offs_hadrs     (32'h0000_0004),  // input wire [31:0]
	//}
	
	//// wire-in //{
	.ep00_hadrs(w_ep00_hadrs),  .ep00wire     (w_ep00wire),  // input wire [31:0] // output wire [31:0] // 
	.ep01_hadrs(w_ep01_hadrs),  .ep01wire     (w_ep01wire),  // input wire [31:0] // output wire [31:0] // 
	.ep02_hadrs(w_ep02_hadrs),  .ep02wire     (w_ep02wire),  // input wire [31:0] // output wire [31:0] // 
	.ep03_hadrs(w_ep03_hadrs),  .ep03wire     (w_ep03wire),  // input wire [31:0] // output wire [31:0] // 
	.ep04_hadrs(w_ep04_hadrs),  .ep04wire     (w_ep04wire),  // input wire [31:0] // output wire [31:0] // 
	.ep12_hadrs(w_ep02_hadrs),  .ep12wire     (w_ep12wire),  // input wire [31:0] // output wire [31:0] // 
	.ep13_hadrs(w_ep03_hadrs),  .ep13wire     (w_ep13wire),  // input wire [31:0] // output wire [31:0] // 
	.ep16_hadrs(w_ep16_hadrs),  .ep16wire     (w_ep16wire),  // input wire [31:0] // output wire [31:0] // MSPI_EN_CS_WI // {SPI_CH_SELEC, SLOT_CS_MASK}
	.ep17_hadrs(w_ep17_hadrs),  .ep17wire     (w_ep17wire),  // input wire [31:0] // output wire [31:0] // MSPI_CON_WI   // {Mx_SPI_MOSI_DATA_H, Mx_SPI_MOSI_DATA_L}
	.ep1A_hadrs(w_ep1A_hadrs),  .ep1Awire     (w_ep1Awire),  // input wire [31:0] // output wire [31:0] // ERR_LED
	.ep1B_hadrs(w_ep1B_hadrs),  .ep1Bwire     (w_ep1Bwire),  // input wire [31:0] // output wire [31:0] // FPGA_LED
	.ep1C_hadrs(w_ep1C_hadrs),  .ep1Cwire     (w_ep1Cwire),  // input wire [31:0] // output wire [31:0] // H I/F OUT 
	.ep1D_hadrs(w_ep1D_hadrs),  .ep1Dwire     (w_ep1Dwire),  // input wire [31:0] // output wire [31:0] // {INTER_LOCK RELAY, INTER_LOCK LED}
	.ep1E_hadrs(w_ep1E_hadrs),  .ep1Ewire     (w_ep1Ewire),  // input wire [31:0] // output wire [31:0] // GPIB CONTROL // Control Read & Write     
	//}
	
	//// wire-out //{
	.ep20_hadrs(w_ep20_hadrs),  .ep20wire     (w_ep20wire),  // input wire [31:0] // input wire [31:0] //
	.ep21_hadrs(w_ep21_hadrs),  .ep21wire     (w_ep21wire),  // input wire [31:0] // input wire [31:0] //
	.ep22_hadrs(w_ep22_hadrs),  .ep22wire     (w_ep22wire),  // input wire [31:0] // input wire [31:0] //
	.ep23_hadrs(w_ep23_hadrs),  .ep23wire     (w_ep23wire),  // input wire [31:0] // input wire [31:0] //
	.ep24_hadrs(w_ep24_hadrs),  .ep24wire     (w_ep24wire),  // input wire [31:0] // input wire [31:0] // MSPI_FLAG_WO // {Mx_SPI_MISO_DATA_H, Mx_SPI_MISO_DATA_L}
	.ep30_hadrs(w_ep30_hadrs),  .ep30wire     (w_ep30wire),  // input wire [31:0] // input wire [31:0] // {MAGIC CODE_H, MAGIC CODE_L}
	.ep31_hadrs(w_ep31_hadrs),  .ep31wire     (w_ep31wire),  // input wire [31:0] // input wire [31:0] // MASTER MODE LAN IP Address 
	.ep32_hadrs(w_ep32_hadrs),  .ep32wire     (w_ep32wire),  // input wire [31:0] // input wire [31:0] // {FPGA_IMAGE_ID_H, FPGA_IMAGE_ID_L}
	.ep33_hadrs(w_ep33_hadrs),  .ep33wire     (w_ep33wire),  // input wire [31:0] // input wire [31:0] // H I/F IN
	.ep34_hadrs(w_ep34_hadrs),  .ep34wire     (w_ep34wire),  // input wire [31:0] // input wire [31:0] // {FAN#1 FAN SPEED, FAN#0 FAN SPEED}
	.ep35_hadrs(w_ep35_hadrs),  .ep35wire     (w_ep35wire),  // input wire [31:0] // input wire [31:0] // {FAN#3 FAN SPEED, FAN#2 FAN SPEED}
	.ep36_hadrs(w_ep36_hadrs),  .ep36wire     (w_ep36wire),  // input wire [31:0] // input wire [31:0] // {FAN#5 FAN SPEED, FAN#4 FAN SPEED}
	.ep37_hadrs(w_ep37_hadrs),  .ep37wire     (w_ep37wire),  // input wire [31:0] // input wire [31:0] // {FAN#7 FAN SPEED, FAN#6 FAN SPEED}
	.ep38_hadrs(w_ep38_hadrs),  .ep38wire     (w_ep38wire),  // input wire [31:0] // input wire [31:0] // INTER_LOCK
	.ep39_hadrs(w_ep39_hadrs),  .ep39wire     (w_ep39wire),  // input wire [31:0] // input wire [31:0] // {GPIB Switch Read, GPIB Status Read}
	.ep3A_hadrs(w_ep3A_hadrs),  .ep3Awire     (w_ep3Awire),  // input wire [31:0] // input wire [31:0] //
	.ep3B_hadrs(w_ep3B_hadrs),  .ep3Bwire     (w_ep3Bwire),  // input wire [31:0] // input wire [31:0] //
	//}
	
	//// trig-in //{
	.ep40_hadrs(w_ep40_hadrs),  .ep40ck       (w_ep40ck),  .ep40trig   (w_ep40trig),  // input wire [31:0] // input wire  // output wire [31:0] //
	.ep42_hadrs(w_ep42_hadrs),  .ep42ck       (w_ep42ck),  .ep42trig   (w_ep42trig),  // input wire [31:0] // input wire  // output wire [31:0] // MSPI_TI // Mx_SPI_Trig
	.ep50_hadrs(w_ep50_hadrs),  .ep50ck       (w_ep50ck),  .ep50trig   (w_ep50trig),  // input wire [31:0] // input wire  // output wire [31:0] // S/W Reset
	.ep51_hadrs(w_ep51_hadrs),  .ep51ck       (w_ep51ck),  .ep51trig   (w_ep51trig),  // input wire [31:0] // input wire  // output wire [31:0] // {PRE_Trig, Trig}
	.ep52_hadrs(w_ep52_hadrs),  .ep52ck       (w_ep52ck),  .ep52trig   (w_ep52trig),  // input wire [31:0] // input wire  // output wire [31:0] // SOT
	.ep53_hadrs(w_ep53_hadrs),  .ep53ck       (w_ep53ck),  .ep53trig   (w_ep53trig),  // input wire [31:0] // input wire  // output wire [31:0] //
	//}
	
	//// trig-out //{
	.ep60_hadrs(w_ep60_hadrs),  .ep60ck       (w_ep60ck),  .ep60trig   (w_ep60trig),  // input wire [31:0] // input wire  // input wire [31:0] //
	.ep62_hadrs(w_ep62_hadrs),  .ep62ck       (w_ep62ck),  .ep62trig   (w_ep62trig),  // input wire [31:0] // input wire  // input wire [31:0] // MSPI_TO // Mx_SPI_DONE
	.ep73_hadrs(w_ep73_hadrs),  .ep73ck       (w_ep73ck),  .ep73trig   (w_ep73trig),  // input wire [31:0] // input wire  // input wire [31:0] //
	//}
	
	//// pipe-in //{
	.ep93_hadrs(w_ep93_hadrs),  .ep93wr       (w_ep93wr),  .ep93pipe   (w_ep93pipe),  // input wire [31:0] // output wire  // output wire [31:0]
	//}
	
	//// pipe-out //{
	.epB3_hadrs(w_epB3_hadrs),  .epB3rd       (w_epB3rd),  .epB3pipe   (w_epB3pipe),  // input wire [31:0] // output wire  // input wire [31:0]
	//}
	
	//// pipe-ck //{
	.epPPck       (w_ck_core),  // output wire  // sync with write/read of pipe
	//}
	
	// test //{
	.valid    ()
	//}
);



wire w_BUF_DATA_DIR; wire w_nBUF_DATA_OE; //{

assign  BUF_DATA_DIR = ~w_nBOE;                                   // w_BUF_DATA_DIR;
assign  nBUF_DATA_OE = w_nBNE1 & w_nBNE2 & w_nBNE3 & w_nBNE4;     // w_nBUF_DATA_OE;

//}


//---------------Address Decode  (to remove ) ---------------// //{


//----------- Address Decode Wrire DATA w_nCS_USB_sig -------------------//
// USB RX DATA x


//address_decode  address_decode__inst (
//	.clk           (sys_clk  ),    // system 10MHz      for valid
//	.reset_n       (reset_n  ),    //

//	.BA25_20       (w_BA25_20),    // 
//	.BA19_18       (w_BA19_18),    // 
//	.BA7_2         (w_BA7_2),      // 
	
//	.nCS1          (w_nBNE1),
//	.nCS2          (w_nBNE2),
//	.nCS3          (w_nBNE3),
//	.nCS4          (w_nBNE4),
	
//	.nOE           (w_nBOE),
//	.nWE           (w_nBWE),
	
//	.o_nBCS        (w_nBCS ),
//	.valid         (       )
//	);	

//wire w_nCS_FPGA_sig;            //(0)  nCS_FPGA_sig         Don't Used
//wire w_nCS_REG_sig;             //(1)  nCS_REG_sig			0x6010 0000 ~ 0x6010 007C
//wire w_nCS_USB_sig;             //(2)  nCS_USB_sig			0x6020 0000 ~ 
//wire w_nCS_GPIB_sig;            //(3)  nCS_GPIB_sig			0x6030 0000 ~ 0x6030 0008
//wire w_GPIB_nCS_sig;            //(4)  GPIB_nCS_sig			0x6040 0000 ~
//wire w_SUB_nCS_sig;             //(5)  SUB_nCS_sig			0x6050 0000 ~

//wire w_SPI_CS_CONTROL_CS;       //(6)  SPI_CS_CONTROL_CS	0x6060 0000 ~ 0x6060 0014
//wire w_Mx_SPI_TRX_CONFIG_CS;    //(7)  Mx_SPI_TRX_CONFIG_CS 0x6070 0000 ~ 0x6070 0010 

//wire w_Trig_CONFIG_CS;          //(10) Trig_CONFIG_CS 		0x60A0 0000 ~ 0x60A0 0008 

//}


//------ ETH SETING_W5300 -----------------//

assign  ETH_nCS     = w_nBNE2;
assign  ETH_nRESET  = reset_n;
assign  FPGA_GPIO_PH7 = ETH_nIRQ;

//------ GPIB SETING_TNT4882 -----------------//

wire w_GPIB_nCS_sig         = ( (!w_nBNE1) & (w_FMC_ADD[31:20]==12'h604) )? 1'b1 : 1'b0; //(4)  GPIB_nCS_sig		   0x6040 0000 ~ 0x604F FFFF
assign  GPIB_nCS        = w_GPIB_nCS_sig;
assign  GPIB_nRESET     = reset_n;
assign  GPIB_DATA_DIR   = ~w_nBOE;
assign  GPIB_DATA_nOE   = w_GPIB_nCS_sig;


//	 GPIB Switch Read
wire w_GPIB_SW_nOE;

//assign w_GPIB_SW_nOE  =  (w_nCS_GPIB_sig == 1'b0 && w_BA7_2 == 6'b00_0010 && w_nBOE == 1'b0) ?   1'b0 :  1'b1;
assign w_GPIB_SW_nOE  =  ( (!w_nBNE1) & (w_FMC_ADD==32'h6030_0008) & (w_nBOE == 1'b0) )? 1'b0 : 1'b1;
assign GPIB_SW_nOE  = w_GPIB_SW_nOE;


//}


/* TODO: FPGA_RUN_LED assign */ //{

wire FPGA_LED_RUN_STATUS;
wire FPGA_LED_RUN_STATUS_FAST;
wire w_CLK_4HZ;

led_test  led_test__inst (
	.clk           (sys_clk            ),          // system 10MHz 
	.reset_n       (reset_n            ),
	.o_run_led     (FPGA_LED_RUN_STATUS),          // 250 msec     4Hz
	.o_run_led_fast(FPGA_LED_RUN_STATUS_FAST),     // 100 msec     10Hz
	.valid         (                   )
	);	

assign RUN_FPGA_LED = FPGA_LED_RUN_STATUS;
assign w_CLK_4HZ = FPGA_LED_RUN_STATUS;

//}


/* TODO: LED assign */ //{

//  assign led[0] = FPGA_LED_RUN_STATUS;
//  assign led[1] = ~FPGA_LED_RUN_STATUS; 
//  assign led[2] = 1'b0;
//  assign led[3] = 1'b1;
//  
//  assign led[4] = FPGA_LED_RUN_STATUS; 
//  assign led[5] = ~FPGA_LED_RUN_STATUS;
//  assign led[6] = 1'b0;
//  assign led[7] = 1'b1;

assign led[0] = ~(FPGA_LED_RUN_STATUS & FPGA_LED_RUN_STATUS_FAST);
assign led[1] = FPGA_LED_RUN_STATUS_FAST; 
assign led[2] = 1'b1;
assign led[3] = 1'b1;

assign led[4] = w_FPGA_LED[0];
assign led[5] = w_FPGA_LED[1];
assign led[6] = w_FPGA_LED[2];
assign led[7] = w_FPGA_LED[3];


//}


/* TODO: TP assign */ //{

//  assign test_point[0] = w_SSPI_TEST_MCLK;
//  assign test_point[1] = w_SSPI_TEST_MOSI; 
//  assign test_point[2] = w_SSPI_TEST_SS_B;
//  assign test_point[3] = 1'b0; 
//  
//  assign test_point[4] = 1'b1; 
//  assign test_point[5] = 1'b0; 
//  assign test_point[6] = FPGA_LED_RUN_STATUS;  
//  assign test_point[7] = ~FPGA_LED_RUN_STATUS; 

//
assign test_point[0] = w_SW_RESET; // w_TI_adrs_cs_SW_RESET;
assign test_point[1] = w_MSPI_TI[0]; // w_TI_adrs_cs_SPI_RESET; 
assign test_point[2] = w_MSPI_TI[1]; // w_TI_adrs_cs_SPI_INIT;
assign test_point[3] = w_MSPI_TI[2]; // w_TI_adrs_cs_SPI_FEAME; 

assign test_point[4] = w_SSPI_TEST_SS_B; 
assign test_point[5] = w_SSPI_TEST_MCLK; 
assign test_point[6] = w_SSPI_TEST_MOSI;  
assign test_point[7] = w_SSPI_TEST_MISO; 

//}


/* TODO: FPGA_IO[0:5] Front LED assign */ //{
wire [5:0] w_FPGA_IO = ~w_ep1Awire[21:16];

//$$ do not use 1'bz
//assign w_FPGA_IO[0] = 1'b0; // 1'bz;
//assign w_FPGA_IO[1] = 1'b0; // 1'bz;
//assign w_FPGA_IO[2] = 1'b0; // 1'bz;
//assign w_FPGA_IO[3] = 1'b0; // 1'bz;
//assign w_FPGA_IO[4] = 1'b0; // 1'bz;
//assign w_FPGA_IO[5] = 1'b0; // 1'bz;

assign FPGA_IO0 = w_FPGA_IO[0];
assign FPGA_IO1 = w_FPGA_IO[1];
assign FPGA_IO2 = w_FPGA_IO[2];
assign FPGA_IO3 = w_FPGA_IO[3];
assign FPGA_IO4 = w_FPGA_IO[4];
assign FPGA_IO5 = w_FPGA_IO[5];

//}


/* TODO: MBD_RS_422_EN assign */ //{

wire w_FPGA_MBD_RS_422_SPI_EN;
wire w_FPGA_MBD_RS_422_TRIG_EN;

assign w_FPGA_MBD_RS_422_SPI_EN  = 1'b0;        // LOW Active
assign w_FPGA_MBD_RS_422_TRIG_EN = 1'b0;        // LOW Active

assign FPGA_MBD_RS_422_SPI_EN = w_FPGA_MBD_RS_422_SPI_EN;
assign FPGA_MBD_RS_422_TRIG_EN = w_FPGA_MBD_RS_422_TRIG_EN;

//}

endmodule
