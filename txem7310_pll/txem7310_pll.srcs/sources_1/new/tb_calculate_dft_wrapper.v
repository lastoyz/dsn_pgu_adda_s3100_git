`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: tb_calculate_dft_wrapper
// 
//----------------------------------------------------------------------------
// http://www.asic-world.com/verilog/art_testbench_writing1.html
// http://www.asic-world.com/verilog/art_testbench_writing2.html
// https://www.xilinx.com/support/documentation/sw_manuals/xilinx2016_1/ug937-vivado-design-suite-simulation-tutorial.pdf
//
//
// test  calculate_dft_wrapper.v
//
//////////////////////////////////////////////////////////////////////////////////

//// read file example //{
// https://www.angelfire.com/in/verilogfaq/pli.html
// https://www.edaboard.com/threads/how-to-read-a-text-file-in-verilog-in-which-the-text-has-signed-floating-values.289374/
// https://stackoverflow.com/questions/20803872/display-in-verilog-and-printf-in-c
// https://sunshowers.tistory.com/10

////  simple ex
//  integer in,i,out;
//  real data;
//  
//  initial begin
//  in = $fopen("input.txt,"rb"); // rb -> r
//  out = $fopen("output","w");
//  
//  if(!in) $display("File Open Error!");
//  if(!out) $display("File Open Error!");
//  
//  i = $fscanf(in,"%f",data);
//  i = $fwrite(out,"%f",data);
//  $fclose(in);
//  $fclose(out);
//  end


////  Reading pattern files
//  This first example shows how to read input stimulus from a text file.
//  This is the pattern file - read_pattern.pat , included in the examples directory:
//  
//  // This is a pattern file
//  // time bin dec hex
//  10: 001 1 1
//  20.0: 010 20 020
//  50.02: 111 5 FFF
//  62.345: 100 4 DEADBEEF
//  75.789: XXX 2 ZzZzZzZz
//  
//  Note that the binary and hexadecimal values have X and Z values, but these are not allowed in the decimal values. You can use white space when formatting your file to make it more readable. Lastly, any line beginning with a / is treated as a comment.
//  The module read_pattern.v reads the time for the next pattern from an ASCII file. It then waits until the absolute time specified in the input file, and reads the new values for the input signals (bin, dec, hex). The time in the file is a real value and, when used in a delay, is rounded according to the timescale directive. Thus the time 75.789 is rounded to 75.79 ns.
//  
//  `timescale 1ns / 10 ps 
//  `define EOF 32'hFFFF_FFFF 
//  `define NULL 0 
//  `define MAX_LINE_LENGTH 1000 
//    
//  module read_pattern; 
//  integer file, c, r; 
//  reg [3:0] bin; 
//  reg [31:0] dec, hex; 
//  real real_time; 
//  reg [8*`MAX_LINE_LENGTH:0] line; /* Line of text read from file */ 
//    
//  initial 
//      begin : file_block 
//      $timeformat(-9, 3, "ns", 6); 
//      $display("time bin decimal hex"); 
//      file = $fopenr("read_pattern.pat"); 
//      if (file == `NULL) // If error opening file 
//          disable file_block; // Just quit 
//    
//      c = $fgetc(file); 
//      while (c != `EOF) 
//          begin 
//          /* Check the first character for comment */ 
//          if (c == "/") 
//              r = $fgets(line, `MAX_LINE_LENGTH, file); 
//          else 
//              begin 
//              // Push the character back to the file then read the next time 
//              r = $ungetc(c, file); 
//              r = $fscanf(file," %f:\n", real_time); 
//    
//              // Wait until the absolute time in the file, then read stimulus 
//              if ($realtime > real_time) 
//                  $display("Error - absolute time in file is out of order - %t", 
//                          real_time); 
//                  else 
//                      #(real_time - $realtime) 
//                          r = $fscanf(file," %b %d %h\n",bin,dec,hex); 
//                  end // if c else 
//              c = $fgetc(file); 
//          end // while not EOF 
//    
//      r = $fcloser(file); 
//      end // initial 
//    
//  // Display changes to the signals 
//  always @(bin or dec or hex) 
//      $display("%t %b %d %h", $realtime, bin, dec, hex); 
//    
//  endmodule // read_pattern


////  Comparing outputs with expected results
//  The following model, compare.v, reads a file containing both stimulus and expected results. The input signals are toggled at the beginning of a clock cycle and the output is compared just before the end of the cycle. 
//    
//  `define EOF 32'hFFFF_FFFF 
//  `define NULL 0 
//  `define MAX_LINE_LENGTH 1000 
//  module compare; 
//  integer file, r; 
//  reg a, b, expect, clock; 
//  wire out; 
//  reg [`MAX_LINE_LENGTH*8:1]; 
//  parameter cycle = 20; 
//    
//  initial 
//      begin : file_block 
//      $display("Time Stim Expect Output"); 
//      clock = 0; 
//  
//      file = $fopenr("compare.pat"); 
//      if (file == `NULL) 
//          disable file_block; 
//    
//      r = $fgets(line, MAX_LINE_LENGTH, file); // Skip comments 
//      r = $fgets(line, MAX_LINE_LENGTH, file); 
//  
//      while (!$feof(file)) 
//          begin 
//          // Wait until rising clock, read stimulus 
//          @(posedge clock) 
//          r = $fscanf(file, " %b %b %b\n", a, b, expect); 
//    
//          // Wait just before the end of cycle to do compare 
//          #(cycle - 1) 
//          $display("%d %b %b %b %b", $stime, a, b, expect, out); 
//          $strobe_compare(expect, out); 
//          end // while not EOF 
//    
//      r = $fcloser(file); 
//      $stop; 
//      end // initial 
//    
//  always #(cycle / 2) clock = !clock; // Clock generator 
//  
//  and #4 (out, a, b); // Circuit under test 
//  endmodule // compare


////  Reading script files
//  Sometimes a detailed simulation model for a device is not available, such as a microprocessor. As a substitute, you can write a bus-functional model which reads a script of bus transactions and performs these actions. The following, script.v, reads a file with commands plus data values. 
//    
//  `define EOF 32'hFFFF_FFFF 
//  `define NULL 0 
//  module script; 
//  integer file, r; 
//  reg [80*8:1] command; 
//  reg [31:0] addr, data; 
//    
//  initial 
//      begin : file_block 
//      clock = 0; 
//    
//      file = $fopenr("script.txt"); 
//      if (file == `NULL) 
//          disable file_block; 
//    
//      while (!$feof(file)) 
//          begin 
//          r = $fscanf(file, " %s %h %h \n", command, addr, data); 
//          case (command) 
//          "read": 
//              $display("READ mem[%h], expect = %h", addr, data); 
//          "write": 
//              $display("WRITE mem[%h] = %h", addr, data); 
//          default: 
//              $display("Unknown command '%0s'", command); 
//          endcase 
//          end // while not EOF 
//    
//      r = $fcloser(file); 
//      end // initial 
//  endmodule // script 
//  
//  The file script.txt is the script read by the above model:
//  read 9 0
//  write 300a feedface
//  read 2FF xxxxxxxx
//  bad


////  Reading data files into memories
//  Reading a formatted ASCII file is easy with the system tasks. The following is an example of reading a binary file into a Verilog memory. $fread can also read a file one word at a time and copy the word into memory, but this is about 100 times slower than using $fread to read the entire array directly.
//  This is the file load_mem.v
//  
//  `define EOF 32'HFFFF_FFFF 
//  `define MEM_SIZE 200_000 
//    
//  module load_mem; 
//    
//  integer file, i; 
//  reg [7:0] mem[0:`MEM_SIZE]; 
//  reg [80*8:1] file_name; 
//    
//  initial 
//      begin 
//      file_name = "data.bin"; 
//      file = $fopenr(file_name); 
//      i = $fread(file, mem[0]); 
//      $display("Loaded %0d entries \n", i); 
//      i = $fcloser(file); 
//      $stop; 
//      end 
//    
//  endmodule // load_mem 

//// $readmemb  vs $readmemh 
//// $writememb vs $writememh
//  integer i;
//  reg [7:0] memory [0:15]; // 8 bit memory with 16 entries
//  
//  initial begin
//      for (i=0; i<16; i++) begin
//          memory[i] = i;
//      end
//      $writememb("memory_binary.txt", memory);
//      $writememh("memory_hex.txt", memory);
//  end


////  $display("<format>", exp1, exp2, ...);  // formatted write to display
//  format indication %b %B binary
//                    %c %C character (low 8 bits)
//                    %d %D decimal  %0d for minimum width field
//                    %e %E E format floating point %15.7E
//                    %f %F F format floating point %9.7F
//                    %g %G G general format floating point
//                    %h %H hexadecimal                         <<<<<<
//                    %l %L library binding information
//                    %m %M hierarchical name, no expression
//                    %o %O octal
//                    %s %S string, 8 bits per character, 2´h00 does not print
//                    %t %T simulation time, expression is  $time
//                    %u %U unformatted two value data  0 and 1  <<<<<<
//                    %v %V net signal strength
//                    %z %Z unformatted four value data  0, 1, x, z
//  
//  escape sequences, quoted characters in strings \n   newline
//                                                 \t   tab
//                                                 \\   backslash
//                                                 \"   quote
//                                                 \ddd octal
//                                                 %%   percent
//  
//  any other characters between the quotes are displayed
//  the expressions are taken in order of the format indication
//  ,, in the expression list inserts one space in the output


//}


////  OPEN A FILE ! not supported in vivado
// https://www.scribd.com/document/382799394/Verilog-Interview-Question
//  
//  integer file;
//  file = $fopenr("filename");
//  file = $fopenw("filename");
//  file = $fopena("filename");
//  
//  The function $fopenr opens an existing file for reading. 
//  $fopenw opens a new file for writing, and $fopena opens a new file for writing 
//  where any data will be appended to the end of the file. The filename can be 
//  either a quoted string or a reg holding the file name. 
//  If the file was successfully opened, itreturns an integer containing 
//  the file number (1..MAX_FILES) or NULL (0) if there was an error. 
//  Note that these functions are not the same as the built-in system function $fopen 
//  which opens a file for writing by $fdisplay. 
//  The files are opened in C with 'rb', 'wb', and 'ab' which allows 
//  reading and writing binary dataon the PC. The 'b' is ignored on Unix.
//
// CLOSE A FILE
//
// integer file, r;
// r = $fcloser(file);
// r = $fclosew(file);
//
// The function $fcloser closes a file for input. $fclosew closes a file for output. It returns EOF if there was
// an error, otherwise 0. Note that these are not the same as $fclose which closes files for writing.

//// File I/O Tasks
// https://www.xilinx.com/support/documentation/sw_manuals/xilinx11/ism_r_verlang_system_tasks.htm

////https://www.xilinx.com/support/documentation/sw_manuals/xilinx2019_1/ug835-vivado-tcl-commands.pdf

//// dft data files: must be in proj source
//      adc_data_2ch__129450.txt  : 123 123
//      fft_coef_from__exp__129450_863.csv :   0.9213 -0.12312

//// note output file is located at :
// ...\sim_5__calculate_dft_wrapper\behav\xsim

//parameter ROOT_SIM = "/home/local/some/fixed/path/to/stimulus/";
//fid = $fopen( {ROOT_SIM, gauss_fn}, "rb");

//// real (double) vs shortreal (float)
// The real data type is from Verilog-2001, and is the same as a C double. 
// The shortreal data type is a SystemVerilog data type, and is the same as a C float. 
// ... it's not only about being 32 or 64 bit data type its more about precision.

//// Real Numbers  in  vivado
// https://forums.xilinx.com/t5/Synthesis/32-bit-float-in-verilog/td-p/962700
// https://www.xilinx.com/support/documentation/sw_manuals/xilinx2018_2/ug901-vivado-synthesis.pdf
//
// Synthesis supports real numbers; however, they cannot be used to create logic. They can
// only be used as parameter values. The SystemVerilog-supported real types are:
// • real
// • shortreal
// • realtime

//// https://stackoverflow.com/questions/39623511/vivado-2016-2-simulator-doesnt-support-system-verilog-cast-or-sformatf

//// support shortreal     
// https://www.xilinx.com/support/documentation/sw_manuals/xilinx2017_4/ug900-vivado-logic-simulation.pdf
// how to setup system verilog



//// testbench for controller
module tb_calculate_dft_wrapper; //{

//// clock and reset //{

reg clk_10M = 1'b0; //10MHz or 100ns
	always
	#50 	clk_10M = ~clk_10M; // toggle every 50ns --> clock 100ns 

wire sys_clk = clk_10M;

reg reset_n = 1'b0;
wire reset = ~reset_n;

reg clk_60M = 1'b0; // 60MHz or 16.6666667ns
	always
	#8.33333333 clk_60M = ~clk_60M; 

wire adc_fifo_clk = clk_60M;

reg clk_144M = 1'b0; // 144MHz
reg clk_72M = 1'b0; // 72MHz

always begin
	#3.47222222;
	clk_144M = ~clk_144M; // toggle every 3.47222222 ns --> clock 6.94444444 ns
	clk_72M = ~clk_72M;
	#3.47222222 
	clk_144M = ~clk_144M; // toggle every 3.47222222 ns --> clock 6.94444444 ns
	end
	
wire mcs_clk = clk_72M;


//}



////---- dut ----////


reg         r_dft_coef_adrs_clear = 1'b0; // from adc fifo logic
reg         r_acc_clear           = 1'b0; // from adc fifo logic
reg         r_trig_fifo_wr_en     = 1'b0; // from adc fifo logic
reg         r_trig_dft_coef_load  = 1'b0; // from adc fifo logic
reg         r_trig_dft_coef_wr_en = 1'b0; // from adc fifo logic


//// calculate_dft_wrapper //{

wire w_dft_coef_adrs_clear = r_dft_coef_adrs_clear;
wire w_acc_clear           = r_acc_clear          ;
wire w_trig_fifo_wr_en     = r_trig_fifo_wr_en    ;

wire [17:0] w_adc_data_int18_dout0;
wire [17:0] w_adc_data_int18_dout1;

wire [31:0] w_dft_coef_flt32_re;
wire [31:0] w_dft_coef_flt32_im;

wire [31:0] w_acc_flt32_re_dout0;
wire [31:0] w_acc_flt32_im_dout0;
wire [31:0] w_acc_flt32_re_dout1;
wire [31:0] w_acc_flt32_im_dout1;

wire        w_dft_coef_wr_adrs_clear    = r_dft_coef_adrs_clear;
wire        w_mcs_dft_coef_re_wren      = r_trig_dft_coef_wr_en;
wire        w_mcs_dft_coef_im_wren      = r_trig_dft_coef_wr_en;
wire [31:0] w_mcs_dft_coef_flt32_re_din = w_dft_coef_flt32_re;
wire [31:0] w_mcs_dft_coef_flt32_im_din = w_dft_coef_flt32_im;

wire w_pulse_monitor;


calculate_dft_wrapper  calculate_dft_wrapper__inst (
	.clk                 (sys_clk), // assume 10MHz or 100ns // io control
	.reset_n             (reset_n),

	.clk_fifo            (adc_fifo_clk), // 60MHz
	.clk_mcs             (mcs_clk),      // 72MHz or 100.8MHz

	// controls
	.i_dft_coef_adrs_clear  (w_dft_coef_adrs_clear),
	.i_acc_clear            (w_acc_clear          ),
	.i_trig_fifo_wr_en      (w_trig_fifo_wr_en    ),

	// ports - data in and acc out
	.i_adc_data_int18_dout0 (w_adc_data_int18_dout0), // [17:0] 
	.i_adc_data_int18_dout1 (w_adc_data_int18_dout1), // [17:0] 
	
	.o_acc_flt32_re_dout0   (w_acc_flt32_re_dout0), // [31:0] 
	.o_acc_flt32_im_dout0   (w_acc_flt32_im_dout0), // [31:0] 
	.o_acc_flt32_re_dout1   (w_acc_flt32_re_dout1), // [31:0] 
	.o_acc_flt32_im_dout1   (w_acc_flt32_im_dout1), // [31:0] 

	// ports - coef write
	.i_dft_coef_wr_adrs_clear    (w_dft_coef_wr_adrs_clear   ),
	.i_mcs_dft_coef_re_wren      (w_mcs_dft_coef_re_wren     ), //        
	.i_mcs_dft_coef_im_wren      (w_mcs_dft_coef_im_wren     ), //        
	.i_mcs_dft_coef_flt32_re_din (w_mcs_dft_coef_flt32_re_din), // [31:0] 
	.i_mcs_dft_coef_flt32_im_din (w_mcs_dft_coef_flt32_im_din), // [31:0] 

	// port - monitor
	.o_pulse_monitor (w_pulse_monitor), // every acc load

	.valid           ()
);
//}


//// load adc test data : reading adc_data__dec_hex.txt 129450 //{
wire        w_adc_data_load = r_trig_fifo_wr_en; //w_pulse_seq1; // r_adc_data_rden;
//
tb_test_file__adc_data   tb_test_file__adc_data__inst(
	.clk                      (adc_fifo_clk          ),
	.load                     (w_adc_data_load       ),
	.o_adc_data_int18_dout0   (w_adc_data_int18_dout0), // [17:0]
	.o_adc_data_int18_dout1   (w_adc_data_int18_dout1)  // [17:0]
); 

//}


//// load dft coef from file: dft_coef_from__npfft__129450_863__dec_hex.txt //{
wire w_dft_coef_load = r_trig_dft_coef_load;
//
tb_test_file__dft_coef   tb_test_file__dft_coef__inst(
	.clk                      (mcs_clk               ),
	.load                     (w_dft_coef_load       ),
	.o_dft_coef_flt32_re      (w_dft_coef_flt32_re   ), // [31:0]
	.o_dft_coef_flt32_im      (w_dft_coef_flt32_im   )  // [31:0]
);

//}



////---- verify ----////

//// acc prod verification //{
// load acc prod of adc and coef 
// reading acc_prod_data_coef__dec_hex.txt 
//reg         r_verify_data_rden = 1'b0;
//
wire        w_verify_data_load = w_pulse_monitor; //w_pulse_seq4; // r_verify_data_rden;
//
wire [31:0] w_prod_data_flt32_re_dout0;
wire [31:0] w_prod_data_flt32_im_dout0;
wire [31:0] w_prod_data_flt32_re_dout1;
wire [31:0] w_prod_data_flt32_im_dout1;
//
wire [31:0] w_acc_data_flt32_re_dout0;
wire [31:0] w_acc_data_flt32_im_dout0;
wire [31:0] w_acc_data_flt32_re_dout1;
wire [31:0] w_acc_data_flt32_im_dout1;
//
tb_test_file__acc_prod_adc_coef_data   tb_test_file__acc_prod_adc_coef_data__inst(
	.clk                         (adc_fifo_clk              ),
	.load                        (w_verify_data_load        ),
	//
	.o_prod_data_flt32_re_dout0  (w_prod_data_flt32_re_dout0), // [31:0]
	.o_prod_data_flt32_im_dout0  (w_prod_data_flt32_im_dout0), // [31:0]
	.o_prod_data_flt32_re_dout1  (w_prod_data_flt32_re_dout1), // [31:0]
	.o_prod_data_flt32_im_dout1  (w_prod_data_flt32_im_dout1),  // [31:0]
	//
	.o_acc_data_flt32_re_dout0   (w_acc_data_flt32_re_dout0 ), // [31:0]
	.o_acc_data_flt32_im_dout0   (w_acc_data_flt32_im_dout0 ), // [31:0]
	.o_acc_data_flt32_re_dout1   (w_acc_data_flt32_re_dout1 ), // [31:0]
	.o_acc_data_flt32_im_dout1   (w_acc_data_flt32_im_dout1 )  // [31:0]
); 

//}

////---- ----////

// system reset 
initial begin : reset_n__gen
#0	reset_n 	= 1'b0;
#200;
	reset_n 	= 1'b1; 
#200;
end

// test seq
initial begin : top_block
	// NOP
#200;
#200;
	//// see blk mem
	SEQ_CLEAR();
#200;
	SEQ_SETUP();
#200;

//	repeat (130000) begin  // 129450
//	SEQ_LOOP();
//	end
	SEQ_LOOP__ADC_DATA_IN();
	
	SEQ_CLEAR();
#200;
	
	$finish;
end

//// task //{

task SEQ_CLEAR;
	begin 
		// clear all controls
		@(posedge adc_fifo_clk);
		r_trig_fifo_wr_en = 1'b0;
		//
		//r_dft_coef_rden    = 1'b0;
		//r_adc_data_rden    = 1'b0;
		//r_adc_int_flt_conv = 1'b0;
		//r_acc_conv         = 1'b0;
		//r_acc_load         = 1'b0;
		//r_verify_data_rden = 1'b0;
	end
endtask

task SEQ_SETUP;
	begin
	//DFT_COEF_ADRS_UPDATE(17'd000_000);
	RESET_DFT_COEF_ADRS();
	RESET_ACC();
	
	// write dft coef 
	SEQ_LOOP__DFT_COEF_IN();
	
	RESET_DFT_COEF_ADRS();
	
	end
endtask

task CYCLE__ADC_DATA_IN;
	begin
		@(posedge adc_fifo_clk);
		r_trig_fifo_wr_en = 1'b1;
		@(posedge adc_fifo_clk);
		r_trig_fifo_wr_en = 1'b0;
		@(posedge adc_fifo_clk);
		r_trig_fifo_wr_en = 1'b0;
		@(posedge adc_fifo_clk);
		r_trig_fifo_wr_en = 1'b0;
	end
endtask

task CYCLE__DFT_COEF_IN;
	begin
		@(posedge mcs_clk);
		r_trig_dft_coef_load  = 1'b1;
		r_trig_dft_coef_wr_en = 1'b0;
		@(posedge mcs_clk);
		r_trig_dft_coef_load  = 1'b0;
		r_trig_dft_coef_wr_en = 1'b1;
		@(posedge mcs_clk);
		r_trig_dft_coef_load  = 1'b0;
		r_trig_dft_coef_wr_en = 1'b0;
	end
endtask

task SEQ_LOOP__ADC_DATA_IN;
	begin
	repeat (130000) begin  // 129450
		CYCLE__ADC_DATA_IN();
		end
	end
endtask

task SEQ_LOOP__DFT_COEF_IN;
	begin
	repeat (130000) begin  // 129450
		CYCLE__DFT_COEF_IN();
		end
	end
endtask

//  task SEQ_LOOP;
//  	begin
//  		@(posedge adc_fifo_clk);
//  		r_trig_fifo_wr_en = 1'b1;
//  		@(posedge adc_fifo_clk);
//  		r_trig_fifo_wr_en = 1'b0;
//  		@(posedge adc_fifo_clk);
//  		r_trig_fifo_wr_en = 1'b0;
//  		@(posedge adc_fifo_clk);
//  		r_trig_fifo_wr_en = 1'b0;
//  		//
//  		//  // seq1: read adc data // r_adc_data_rden
//  		//  @(posedge adc_fifo_clk);
//  		//  r_acc_load         = 1'b0;
//  		//  r_verify_data_rden = 1'b0;
//  		//  r_adc_data_rden    = 1'b1;
//  		//  
//  		//  // seq2: conv data int18 into flt32 // r_adc_int_flt_conv
//  		//  // seq2: increase dft coef address  // r_dft_coef_adrs = r_dft_coef_adrs + 1
//  		//  @(posedge adc_fifo_clk);
//  		//  r_adc_data_rden    = 1'b0;
//  		//  r_adc_int_flt_conv = 1'b1;
//  		//  r_dft_coef_adrs = r_dft_coef_adrs + 1; //
//  		//  
//  		//  // seq3: wait for acc convert // r_acc_conv
//  		//  // seq3: read dft coef        // r_dft_coef_rden
//  		//  @(posedge adc_fifo_clk);
//  		//  r_adc_int_flt_conv = 1'b0;
//  		//  r_acc_conv         = 1'b1;
//  		//  r_dft_coef_rden    = 1'b1;
//  		//  
//  		//  // seq4: load acc         // r_acc_load
//  		//  // seq4: read verify data // r_verify_data_rden
//  		//  @(posedge adc_fifo_clk);
//  		//  r_acc_conv         = 1'b0;
//  		//  r_dft_coef_rden    = 1'b0;
//  		//  r_acc_load         = 1'b1;
//  		//  r_verify_data_rden = 1'b1;
//  	end
//  endtask


// reset dft coef 
task RESET_DFT_COEF_ADRS;
	begin 
		@(posedge adc_fifo_clk);
		r_dft_coef_adrs_clear = 1'b1; //
		@(posedge adc_fifo_clk);
		r_dft_coef_adrs_clear = 1'b0; //
	end
endtask 

// reset acc 
task RESET_ACC;
	begin 
		@(posedge adc_fifo_clk);
		r_acc_clear = 1'b1; //
		@(posedge adc_fifo_clk);
		r_acc_clear = 1'b0; //
	end
endtask 


//}

endmodule 
//}


//// see reference data
module tb_calculate_dft_wrapper__ref;  //{

////  call modules
//tb_test_file_io                      tb_test_file_io__inst ();
//tb_test_file_dft_coef                tb_test_file_dft_coef__inst ();
//tb_conv_file__dft_coef_hex__coe_mif  tb_conv_file__dft_coef_hex__coe_mif__inst (); // generate coe and mif for block mem

//// clock and reset //{

reg clk_10M = 1'b0; //10MHz or 100ns
	always
	#50 	clk_10M = ~clk_10M; // toggle every 50ns --> clock 100ns 

reg reset_n = 1'b0;
wire reset = ~reset_n;

reg clk_60M = 1'b0; // 60MHz or 16.6666667ns
	always
	#8.33333333 clk_60M = ~clk_60M; 

wire adc_fifo_clk = clk_60M;
//}

////---- dut ----////

//// test call block mem : dft coef data loaded //{
reg         r_dft_coef_rden = 1'b0;
reg  [16:0] r_dft_coef_adrs = 17'b0;
//
wire        w_dft_coef_regceb = reset_n;
wire [31:0] w_dft_coef_flt32_re_dout;
wire [31:0] w_dft_coef_flt32_im_dout;
//
blk_mem_gen_dft_re_0  blk_mem_gen_dft_re__inst0 (
	.clka  (adc_fifo_clk            ),  // input wire clka
	.wea   (1'b0                    ),  // input wire [0 : 0] wea
	.addra (17'b0                   ),  // input wire [16 : 0] addra
	.dina  (32'b0                   ),  // input wire [31 : 0] dina
	.clkb  (adc_fifo_clk            ),  // input wire clkb
	.enb   (r_dft_coef_rden         ),  // input wire enb
	.regceb(w_dft_coef_regceb       ),  // input wire regceb
	.addrb (r_dft_coef_adrs         ),  // input wire [16 : 0] addrb
	.doutb (w_dft_coef_flt32_re_dout)   // output wire [31 : 0] doutb
);

blk_mem_gen_dft_im_0  blk_mem_gen_dft_im__inst0 (
	.clka  (adc_fifo_clk            ),  // input wire clka
	.wea   (1'b0                    ),  // input wire [0 : 0] wea
	.addra (17'b0                   ),  // input wire [16 : 0] addra
	.dina  (32'b0                   ),  // input wire [31 : 0] dina
	.clkb  (adc_fifo_clk            ),  // input wire clkb
	.enb   (r_dft_coef_rden         ),  // input wire enb
	.regceb(w_dft_coef_regceb       ),  // input wire regceb
	.addrb (r_dft_coef_adrs         ),  // input wire [16 : 0] addrb
	.doutb (w_dft_coef_flt32_im_dout)   // output wire [31 : 0] doutb
);

//}

//// load adc test data : reading adc_data__dec_hex.txt //{
reg         r_adc_data_rden = 1'b0;
//
wire        w_adc_data_load = r_adc_data_rden;
//
wire [17:0] w_adc_data_int18_dout0;
wire [17:0] w_adc_data_int18_dout1;
//
tb_test_file__adc_data   tb_test_file__adc_data__inst(
	.clk                      (adc_fifo_clk          ),
	.load                     (w_adc_data_load       ),
	.o_adc_data_int18_dout0   (w_adc_data_int18_dout0), // [17:0]
	.o_adc_data_int18_dout1   (w_adc_data_int18_dout1)  // [17:0]
); 

//}

////---- calculate ----////

//// convert adc data int18 into single prcs flt32 : call floating_point_int32_sgflt_0 //{
//   note ... floating_point_int18_flt32_0 ip is also possible!!
reg         r_adc_int_flt_conv = 1'b0;
//
wire [31:0] w_adc_data_int32_dout0     = { {14{w_adc_data_int18_dout0[17]}}, w_adc_data_int18_dout0[17:0]};
wire [31:0] w_adc_data_int32_dout1     = { {14{w_adc_data_int18_dout1[17]}}, w_adc_data_int18_dout1[17:0]};
wire        w_adc_data_int32_dout0_vld = r_adc_int_flt_conv; // input
wire        w_adc_data_int32_dout1_vld = r_adc_int_flt_conv; // input
wire [31:0] w_adc_data_flt32_dout0     ;
wire [31:0] w_adc_data_flt32_dout1     ;
wire        w_adc_data_flt32_dout0_vld ; // output
wire        w_adc_data_flt32_dout1_vld ; // output
//
wire        w_adc_int_flt_conv         = r_adc_int_flt_conv;
// ...

//
floating_point_int32_sgflt_0  floating_point_int32_sgflt__dout0_inst (
	.aclk                   (adc_fifo_clk               ),  // input wire aclk
	.aclken                 (w_adc_int_flt_conv         ),  // input wire aclken
	.s_axis_a_tvalid        (w_adc_data_int32_dout0_vld ),  // input wire s_axis_a_tvalid
	.s_axis_a_tdata         (w_adc_data_int32_dout0     ),  // input wire [31 : 0] s_axis_a_tdata
	.m_axis_result_tvalid   (w_adc_data_flt32_dout0_vld ),  // output wire m_axis_result_tvalid
	.m_axis_result_tdata    (w_adc_data_flt32_dout0     )   // output wire [31 : 0] m_axis_result_tdata
);
//
floating_point_int32_sgflt_0  floating_point_int32_sgflt__dout1_inst (
	.aclk                   (adc_fifo_clk                ),  // input wire aclk
	.aclken                 (w_adc_int_flt_conv          ),  // input wire aclken
	.s_axis_a_tvalid        (w_adc_data_int32_dout1_vld  ),  // input wire s_axis_a_tvalid
	.s_axis_a_tdata         (w_adc_data_int32_dout1      ),  // input wire [31 : 0] s_axis_a_tdata
	.m_axis_result_tvalid   (w_adc_data_flt32_dout1_vld  ),  // output wire m_axis_result_tvalid
	.m_axis_result_tdata    (w_adc_data_flt32_dout1      )   // output wire [31 : 0] m_axis_result_tdata
);


// multiply adc and coef  // we can skip...
//wire [31:0] w_prd_calc_flt32_re_dout0;
//wire [31:0] w_prd_calc_flt32_im_dout0;
//wire [31:0] w_prd_calc_flt32_re_dout1;
//wire [31:0] w_prd_calc_flt32_im_dout1;
// ...

//}

//// accumulate the products for dft calcation : call floating_point_mult_add_0 //{
//   C = A*B+C
//   C : accumulator
//   A : adc data 
//   B : dft coef 

reg         r_acc_clear = 1'b0;
reg         r_acc_conv  = 1'b0;
reg         r_acc_load  = 1'b0;

//
reg  [31:0] r_acc_flt32_re_dout0;
reg  [31:0] r_acc_flt32_im_dout0;
reg  [31:0] r_acc_flt32_re_dout1;
reg  [31:0] r_acc_flt32_im_dout1;
//
wire [31:0] w_acc_flt32_re_dout0 = r_acc_flt32_re_dout0;
wire [31:0] w_acc_flt32_im_dout0 = r_acc_flt32_im_dout0;
wire [31:0] w_acc_flt32_re_dout1 = r_acc_flt32_re_dout1;
wire [31:0] w_acc_flt32_im_dout1 = r_acc_flt32_im_dout1;
//
wire        w_acc_data_en              = r_acc_conv; // input

wire        w_acc_flt32_re_dout0_a_vld = r_acc_conv              ; // input
wire [31:0] w_acc_flt32_re_dout0_a     = w_adc_data_flt32_dout0  ; // input
wire        w_acc_flt32_re_dout0_b_vld = r_acc_conv              ; // input
wire [31:0] w_acc_flt32_re_dout0_b     = w_dft_coef_flt32_re_dout; // input
wire        w_acc_flt32_re_dout0_c_vld = r_acc_conv              ; // input
wire [31:0] w_acc_flt32_re_dout0_c     = w_acc_flt32_re_dout0    ; // input
wire        w_acc_flt32_re_dout0_o_vld ; // output
wire [31:0] w_acc_flt32_re_dout0_o     ; // output

wire        w_acc_flt32_im_dout0_a_vld = r_acc_conv              ; // input
wire [31:0] w_acc_flt32_im_dout0_a     = w_adc_data_flt32_dout0  ; // input
wire        w_acc_flt32_im_dout0_b_vld = r_acc_conv              ; // input
wire [31:0] w_acc_flt32_im_dout0_b     = w_dft_coef_flt32_im_dout; // input
wire        w_acc_flt32_im_dout0_c_vld = r_acc_conv              ; // input
wire [31:0] w_acc_flt32_im_dout0_c     = w_acc_flt32_im_dout0    ; // input
wire        w_acc_flt32_im_dout0_o_vld ; // output
wire [31:0] w_acc_flt32_im_dout0_o     ; // output

wire        w_acc_flt32_re_dout1_a_vld = r_acc_conv              ; // input
wire [31:0] w_acc_flt32_re_dout1_a     = w_adc_data_flt32_dout1  ; // input
wire        w_acc_flt32_re_dout1_b_vld = r_acc_conv              ; // input
wire [31:0] w_acc_flt32_re_dout1_b     = w_dft_coef_flt32_re_dout; // input
wire        w_acc_flt32_re_dout1_c_vld = r_acc_conv              ; // input
wire [31:0] w_acc_flt32_re_dout1_c     = w_acc_flt32_re_dout1    ; // input
wire        w_acc_flt32_re_dout1_o_vld ; // output
wire [31:0] w_acc_flt32_re_dout1_o     ; // output

wire        w_acc_flt32_im_dout1_a_vld = r_acc_conv              ; // input
wire [31:0] w_acc_flt32_im_dout1_a     = w_adc_data_flt32_dout1  ; // input
wire        w_acc_flt32_im_dout1_b_vld = r_acc_conv              ; // input
wire [31:0] w_acc_flt32_im_dout1_b     = w_dft_coef_flt32_im_dout; // input
wire        w_acc_flt32_im_dout1_c_vld = r_acc_conv              ; // input
wire [31:0] w_acc_flt32_im_dout1_c     = w_acc_flt32_im_dout1    ; // input
wire        w_acc_flt32_im_dout1_o_vld ; // output
wire [31:0] w_acc_flt32_im_dout1_o     ; // output


floating_point_mult_add_0  acc_flt32_re_dout0__inst (
	.aclk                  (adc_fifo_clk              ),  // input wire aclk
	.aclken                (w_acc_data_en             ),  // input wire aclken
	.s_axis_a_tvalid       (w_acc_flt32_re_dout0_a_vld),  // input wire s_axis_a_tvalid
	.s_axis_a_tdata        (w_acc_flt32_re_dout0_a    ),  // input wire [31 : 0] s_axis_a_tdata
	.s_axis_b_tvalid       (w_acc_flt32_re_dout0_b_vld),  // input wire s_axis_b_tvalid
	.s_axis_b_tdata        (w_acc_flt32_re_dout0_b    ),  // input wire [31 : 0] s_axis_b_tdata
	.s_axis_c_tvalid       (w_acc_flt32_re_dout0_c_vld),  // input wire s_axis_c_tvalid
	.s_axis_c_tdata        (w_acc_flt32_re_dout0_c    ),  // input wire [31 : 0] s_axis_c_tdata
	.m_axis_result_tvalid  (w_acc_flt32_re_dout0_o_vld),  // output wire m_axis_result_tvalid
	.m_axis_result_tdata   (w_acc_flt32_re_dout0_o    )   // output wire [31 : 0] m_axis_result_tdata
);

floating_point_mult_add_0  acc_flt32_im_dout0__inst (
	.aclk                  (adc_fifo_clk              ),  // input wire aclk
	.aclken                (w_acc_data_en             ),  // input wire aclken
	.s_axis_a_tvalid       (w_acc_flt32_im_dout0_a_vld),  // input wire s_axis_a_tvalid
	.s_axis_a_tdata        (w_acc_flt32_im_dout0_a    ),  // input wire [31 : 0] s_axis_a_tdata
	.s_axis_b_tvalid       (w_acc_flt32_im_dout0_b_vld),  // input wire s_axis_b_tvalid
	.s_axis_b_tdata        (w_acc_flt32_im_dout0_b    ),  // input wire [31 : 0] s_axis_b_tdata
	.s_axis_c_tvalid       (w_acc_flt32_im_dout0_c_vld),  // input wire s_axis_c_tvalid
	.s_axis_c_tdata        (w_acc_flt32_im_dout0_c    ),  // input wire [31 : 0] s_axis_c_tdata
	.m_axis_result_tvalid  (w_acc_flt32_im_dout0_o_vld),  // output wire m_axis_result_tvalid
	.m_axis_result_tdata   (w_acc_flt32_im_dout0_o    )   // output wire [31 : 0] m_axis_result_tdata
);

floating_point_mult_add_0  acc_flt32_re_dout1__inst (
	.aclk                  (adc_fifo_clk              ),  // input wire aclk
	.aclken                (w_acc_data_en             ),  // input wire aclken
	.s_axis_a_tvalid       (w_acc_flt32_re_dout1_a_vld),  // input wire s_axis_a_tvalid
	.s_axis_a_tdata        (w_acc_flt32_re_dout1_a    ),  // input wire [31 : 0] s_axis_a_tdata
	.s_axis_b_tvalid       (w_acc_flt32_re_dout1_b_vld),  // input wire s_axis_b_tvalid
	.s_axis_b_tdata        (w_acc_flt32_re_dout1_b    ),  // input wire [31 : 0] s_axis_b_tdata
	.s_axis_c_tvalid       (w_acc_flt32_re_dout1_c_vld),  // input wire s_axis_c_tvalid
	.s_axis_c_tdata        (w_acc_flt32_re_dout1_c    ),  // input wire [31 : 0] s_axis_c_tdata
	.m_axis_result_tvalid  (w_acc_flt32_re_dout1_o_vld),  // output wire m_axis_result_tvalid
	.m_axis_result_tdata   (w_acc_flt32_re_dout1_o    )   // output wire [31 : 0] m_axis_result_tdata
);

floating_point_mult_add_0  acc_flt32_im_dout1__inst (
	.aclk                  (adc_fifo_clk              ),  // input wire aclk
	.aclken                (w_acc_data_en             ),  // input wire aclken
	.s_axis_a_tvalid       (w_acc_flt32_im_dout1_a_vld),  // input wire s_axis_a_tvalid
	.s_axis_a_tdata        (w_acc_flt32_im_dout1_a    ),  // input wire [31 : 0] s_axis_a_tdata
	.s_axis_b_tvalid       (w_acc_flt32_im_dout1_b_vld),  // input wire s_axis_b_tvalid
	.s_axis_b_tdata        (w_acc_flt32_im_dout1_b    ),  // input wire [31 : 0] s_axis_b_tdata
	.s_axis_c_tvalid       (w_acc_flt32_im_dout1_c_vld),  // input wire s_axis_c_tvalid
	.s_axis_c_tdata        (w_acc_flt32_im_dout1_c    ),  // input wire [31 : 0] s_axis_c_tdata
	.m_axis_result_tvalid  (w_acc_flt32_im_dout1_o_vld),  // output wire m_axis_result_tvalid
	.m_axis_result_tdata   (w_acc_flt32_im_dout1_o    )   // output wire [31 : 0] m_axis_result_tdata
);

wire w_acc_clear = r_acc_clear; // input
wire w_acc_load  = r_acc_load ; // input

always @(posedge adc_fifo_clk, negedge reset_n)
	if (!reset_n) begin
		r_acc_flt32_re_dout0 <= 32'b0;
		r_acc_flt32_im_dout0 <= 32'b0;
		r_acc_flt32_re_dout1 <= 32'b0;
		r_acc_flt32_im_dout1 <= 32'b0;
		end 
	else begin
		if (w_acc_clear) begin
			r_acc_flt32_re_dout0 <= 32'b0;
			r_acc_flt32_im_dout0 <= 32'b0;
			r_acc_flt32_re_dout1 <= 32'b0;
			r_acc_flt32_im_dout1 <= 32'b0;
			end
		else if (w_acc_load) begin
			r_acc_flt32_re_dout0 <= w_acc_flt32_re_dout0_o;
			r_acc_flt32_im_dout0 <= w_acc_flt32_im_dout0_o;
			r_acc_flt32_re_dout1 <= w_acc_flt32_re_dout1_o;
			r_acc_flt32_im_dout1 <= w_acc_flt32_im_dout1_o;
			end
		end

//}

////---- verify ----////

//// acc prod verification //{

// load acc prod of adc and coef 
// reading acc_prod_data_coef__dec_hex.txt 

reg         r_verify_data_rden = 1'b0;
//
wire        w_verify_data_load = r_verify_data_rden;
//
wire [31:0] w_prod_data_flt32_re_dout0;
wire [31:0] w_prod_data_flt32_im_dout0;
wire [31:0] w_prod_data_flt32_re_dout1;
wire [31:0] w_prod_data_flt32_im_dout1;
//
wire [31:0] w_acc_data_flt32_re_dout0;
wire [31:0] w_acc_data_flt32_im_dout0;
wire [31:0] w_acc_data_flt32_re_dout1;
wire [31:0] w_acc_data_flt32_im_dout1;
//
tb_test_file__acc_prod_adc_coef_data   tb_test_file__acc_prod_adc_coef_data__inst(
	.clk                         (adc_fifo_clk              ),
	.load                        (w_verify_data_load        ),
	//
	.o_prod_data_flt32_re_dout0  (w_prod_data_flt32_re_dout0), // [31:0]
	.o_prod_data_flt32_im_dout0  (w_prod_data_flt32_im_dout0), // [31:0]
	.o_prod_data_flt32_re_dout1  (w_prod_data_flt32_re_dout1), // [31:0]
	.o_prod_data_flt32_im_dout1  (w_prod_data_flt32_im_dout1),  // [31:0]
	//
	.o_acc_data_flt32_re_dout0   (w_acc_data_flt32_re_dout0 ), // [31:0]
	.o_acc_data_flt32_im_dout0   (w_acc_data_flt32_im_dout0 ), // [31:0]
	.o_acc_data_flt32_re_dout1   (w_acc_data_flt32_re_dout1 ), // [31:0]
	.o_acc_data_flt32_im_dout1   (w_acc_data_flt32_im_dout1 )  // [31:0]
); 

//}

////---- ----////

// system reset 
initial begin : reset_n__gen
#0	reset_n 	= 1'b0;
#200;
	reset_n 	= 1'b1; 
#200;
end

// test seq
initial begin : top_block
	// NOP
#200;
#200;
	//// see blk mem
	//DFT_COEF_ADRS_UPDATE(17'd000_000);
	//RESET_ACC();
	
	SEQ_CLEAR();
#200;
	SEQ_SETUP();
#200;

	repeat (130000) begin  // 129450
	//GEN_CNTL_SEQ();
	//DFT_COEF_ADRS_INC();
	SEQ_LOOP();
	end
	SEQ_CLEAR();
#200;
	
	$finish;
end

//// task //{

task SEQ_CLEAR;
	begin 
		// clear all controls
		@(posedge adc_fifo_clk);
		r_dft_coef_rden    = 1'b0;
		r_adc_data_rden    = 1'b0;
		r_adc_int_flt_conv = 1'b0;
		r_acc_conv         = 1'b0;
		r_acc_load         = 1'b0;
		r_verify_data_rden = 1'b0;
	end
endtask

task SEQ_SETUP;
	begin
	DFT_COEF_ADRS_UPDATE(17'd000_000);
	RESET_ACC();
	end
endtask

task SEQ_LOOP;
	begin
		// seq1: read adc data
		@(posedge adc_fifo_clk);
		r_acc_load         = 1'b0;
		r_verify_data_rden = 1'b0;
		r_adc_data_rden    = 1'b1;
		
		// seq2: conv data int18 into flt32
		// seq2: increase dft coef address
		@(posedge adc_fifo_clk);
		r_adc_data_rden    = 1'b0;
		r_adc_int_flt_conv = 1'b1;
		r_dft_coef_adrs = r_dft_coef_adrs + 1; //
		
		// seq3: wait for acc convert
		// seq3: read dft coef
		@(posedge adc_fifo_clk);
		r_adc_int_flt_conv = 1'b0;
		r_acc_conv         = 1'b1;
		r_dft_coef_rden    = 1'b1;

		// seq4: load acc 
		// seq4: read verify data // monitor
		@(posedge adc_fifo_clk);
		r_acc_conv         = 1'b0;
		r_dft_coef_rden    = 1'b0;
		r_acc_load         = 1'b1;
		r_verify_data_rden = 1'b1;
	end
endtask

// task dft coef update and update controls 
task DFT_COEF_ADRS_UPDATE;
	input  [31:0] adrs;
	begin 
		@(posedge adc_fifo_clk);
		r_dft_coef_adrs = adrs; //
		r_dft_coef_rden    = 1'b1;
		@(posedge adc_fifo_clk);
		r_dft_coef_rden    = 1'b0;
	end
endtask 

//task DFT_COEF_ADRS_INC;
//	begin 
//		@(posedge adc_fifo_clk);
//		r_dft_coef_adrs = r_dft_coef_adrs + 1; //
//	end
//endtask 

// reset acc 
task RESET_ACC;
	begin 
		@(posedge adc_fifo_clk);
		r_acc_clear = 1'b1; //
		@(posedge adc_fifo_clk);
		r_acc_clear = 1'b0; //
	end
endtask 


//}

endmodule 
//}


//// testbench for blk_mem output 
// consider adc output rate ... 210MHz/n <= 15MHz
//   210MHz adc_clk  vs  60MHz adc_fifo_clk  vs  30MHz
// blk mem config ... 32 bit 2EA vs 64 bit 1EA
// 

//// note on  test signaling
// use : 60MHz adc_fifo_clk, adc update every 15MHz or every 4 of 60MHz
//
// sequence 
//     seq 0 -- dft coef address reset
//     seq 0 -- acc reg reset
//     //
//     seq 1 -- adc data update by adc_fifo_clk
//     seq 2 -- float-convert by adc_fifo_clk
//     seq 3 -- mult-add-accumulate by adc_fifo_clk
//     seq 4 -- dft coef address increase by adc_fifo_clk
//     //
//     seq 1 -- repeat seq1~4
//     ...
//     seq 5 -- final update if needed.


//// 
module tb_test_file__acc_prod_adc_coef_data (
	input  wire        clk ,
	input  wire        load,
	//
	output wire [31:0] o_prod_data_flt32_re_dout0,
	output wire [31:0] o_prod_data_flt32_im_dout0,
	output wire [31:0] o_prod_data_flt32_re_dout1,
	output wire [31:0] o_prod_data_flt32_im_dout1,
	//
	output wire [31:0] o_acc_data_flt32_re_dout0,
	output wire [31:0] o_acc_data_flt32_im_dout0,
	output wire [31:0] o_acc_data_flt32_re_dout1,
	output wire [31:0] o_acc_data_flt32_im_dout1
); //{

parameter DIR_SIM   = "/media/sf_temp/dsn_cmu_git/xem7310_pll__CMU-CPU__work/xem7310_pll.srcs/sources_1/new/";
parameter FILE_NAME = "acc_prod_data_coef__dec_hex.txt"; 

//// read files
integer file_in, ret_int, cnt_line; // file io var
reg [512*8:1] row; // string is not supported
reg [16:1] cc;

// data in a row
real       data_adc0_____flt32 = 0;
real       data_adc1_____flt32 = 0;
real       data_coef_re__flt32 = 0;
real       data_coef_im__flt32 = 0;
real       prod_re_dout0_flt32 = 0;
real       prod_im_dout0_flt32 = 0;
real       prod_re_dout1_flt32 = 0;
real       prod_im_dout1_flt32 = 0;
real       accm_re_dout0_flt32 = 0;
real       accm_im_dout0_flt32 = 0;
real       accm_re_dout1_flt32 = 0;
real       accm_im_dout1_flt32 = 0;

reg [31:0] data_adc0_____flt32_hex = 0;
reg [31:0] data_adc1_____flt32_hex = 0;
reg [31:0] data_coef_re__flt32_hex = 0;
reg [31:0] data_coef_im__flt32_hex = 0;
reg [31:0] prod_re_dout0_flt32_hex = 0;
reg [31:0] prod_im_dout0_flt32_hex = 0;
reg [31:0] prod_re_dout1_flt32_hex = 0;
reg [31:0] prod_im_dout1_flt32_hex = 0;
reg [31:0] accm_re_dout0_flt32_hex = 0;
reg [31:0] accm_im_dout0_flt32_hex = 0;
reg [31:0] accm_re_dout1_flt32_hex = 0;
reg [31:0] accm_im_dout1_flt32_hex = 0;

 
//
initial begin : file_block
	file_in  = $fopen({DIR_SIM, FILE_NAME},"rb"); 
	//
	if(!file_in) begin
		$display("File Open Error!");
		$finish;
		// disable file_block; 
		end
		
	$display(">>>Reading File!");
	
	cnt_line = 0;
	while (!$feof(file_in)) begin 
		@(posedge clk) // wait for clock
		if (load) begin
			$fgets (row, file_in);
			$sscanf(row,"%2s", cc);
			while (cc=="//") begin // comment or header check 
				$display(">>>%s", row);
				$fgets (row, file_in);
				$sscanf(row,"%2s", cc);
				end
			//
			cnt_line = cnt_line + 1;
			//
			ret_int = $sscanf(row,
				"%f %f %f %f  %f %f %f %f  %f %f %f %f  %h %h %h %h  %h %h %h %h  %h %h %h %h", 
				data_adc0_____flt32     ,
				data_adc1_____flt32     ,
				data_coef_re__flt32     ,
				data_coef_im__flt32     ,
				prod_re_dout0_flt32     ,
				prod_im_dout0_flt32     ,
				prod_re_dout1_flt32     ,
				prod_im_dout1_flt32     ,
				accm_re_dout0_flt32     ,
				accm_im_dout0_flt32     ,
				accm_re_dout1_flt32     ,
				accm_im_dout1_flt32     ,
				data_adc0_____flt32_hex ,
				data_adc1_____flt32_hex ,
				data_coef_re__flt32_hex ,
				data_coef_im__flt32_hex ,
				prod_re_dout0_flt32_hex ,
				prod_im_dout0_flt32_hex ,
				prod_re_dout1_flt32_hex ,
				prod_im_dout1_flt32_hex ,
				accm_re_dout0_flt32_hex ,
				accm_im_dout0_flt32_hex ,
				accm_re_dout1_flt32_hex ,
				accm_im_dout1_flt32_hex );
			//
			if (ret_int>0) begin 
				$display("verify: %6d(%0d)>  %f %f %f %f, %h %h %h %h ", 
					cnt_line, ret_int,
					accm_re_dout0_flt32     ,
					accm_im_dout0_flt32     ,
					accm_re_dout1_flt32     ,
					accm_im_dout1_flt32     ,
					accm_re_dout0_flt32_hex ,
					accm_im_dout0_flt32_hex ,
					accm_re_dout1_flt32_hex ,
					accm_im_dout1_flt32_hex );
				//
				end
			else begin 
				$display("%d (%0d)> ", cnt_line, ret_int);
				end
			end
		end
	$fclose(file_in );
	
	//$finish;
end


//// outputs 
assign o_prod_data_flt32_re_dout0 = prod_re_dout0_flt32_hex;
assign o_prod_data_flt32_im_dout0 = prod_im_dout0_flt32_hex;
assign o_prod_data_flt32_re_dout1 = prod_re_dout1_flt32_hex;
assign o_prod_data_flt32_im_dout1 = prod_im_dout1_flt32_hex;
//
assign o_acc_data_flt32_re_dout0 = accm_re_dout0_flt32_hex;
assign o_acc_data_flt32_im_dout0 = accm_im_dout0_flt32_hex;
assign o_acc_data_flt32_re_dout1 = accm_re_dout1_flt32_hex;
assign o_acc_data_flt32_im_dout1 = accm_im_dout1_flt32_hex;


endmodule
//}


//// note loading data styles: 
//   1. update variable every clock in initial block  
//   2. first store data in memory, and access memory every clock.

//// http://www.asic.co.in/Index_files/verilog_files/File_IO.htm

//// note fscanf has some line width limit ... around 128...
//   must use sscanf!  

////
module tb_test_file__adc_data (
	input  wire        clk                   ,
	input  wire        load                  ,
	output wire [17:0] o_adc_data_int18_dout0,
	output wire [17:0] o_adc_data_int18_dout1
); //{

parameter DIR_SIM   = "/media/sf_temp/dsn_cmu_git/xem7310_pll__CMU-CPU__work/xem7310_pll.srcs/sources_1/new/";
parameter FILE_NAME = "adc_data__dec_hex.txt"; // 129450 length

//// read files
integer file_in, ret_int, cnt_line; // file io var

// data in a row
reg signed [31:0] data_adc0_int32     = 32'b0;
reg signed [31:0] data_adc1_int32     = 32'b0;
real              data_adc0_flt32     = 0    ; // shortreal not supported in vivado
real              data_adc1_flt32     = 0    ; // shortreal not supported in vivado
reg        [31:0] data_adc0_flt32_hex = 32'b0;
reg        [31:0] data_adc1_flt32_hex = 32'b0;
//reg        [63:0] data_adc0_flt64_hex = 64'b0;
//reg        [63:0] data_adc1_flt64_hex = 64'b0;

initial begin : file_block
	file_in  = $fopen({DIR_SIM, FILE_NAME},"rb"); 
	//
	if(!file_in) begin
		$display("File Open Error!");
		$finish;
		// disable file_block; 
		end
		
	$display(">>>Reading File!");
	
	cnt_line = 0;
	while (!$feof(file_in)) begin
		@(posedge clk) 
		if (load) begin
			cnt_line = cnt_line + 1;
			ret_int = $fscanf(file_in,"%d %d  %f %f  %h %h", 
				data_adc0_int32    , data_adc1_int32    ,
				data_adc0_flt32    , data_adc1_flt32    ,
				data_adc0_flt32_hex, data_adc1_flt32_hex);
			
			if (ret_int>0) begin 
				$display("adc: %6d(%0d)>  %d %d  %f %f  %h %h", 
					cnt_line, ret_int,
					data_adc0_int32    , data_adc1_int32    ,
					data_adc0_flt32    , data_adc1_flt32    ,
					data_adc0_flt32_hex, data_adc1_flt32_hex);
				//
				end
				
			end
		end
		
	$fclose(file_in );
	
	//$finish;
end

// outputs 
assign o_adc_data_int18_dout0 = data_adc0_int32[17:0];
assign o_adc_data_int18_dout1 = data_adc1_int32[17:0];

endmodule 
//}


//// reading dft coef from dft_coef_from__npfft__129450_863__dec_hex.txt
module tb_test_file__dft_coef (
	input  wire        clk                   ,
	input  wire        load                  ,
	output wire [31:0] o_dft_coef_flt32_re,
	output wire [31:0] o_dft_coef_flt32_im
); //{

parameter DIR_SIM   = "/media/sf_temp/dsn_cmu_git/xem7310_pll__CMU-CPU__work/xem7310_pll.srcs/sources_1/new/";
parameter FILE_NAME = "dft_coef_from__npfft__129450_863__dec_hex.txt"; // 129450 length

//// read files
integer file_in, ret_int, cnt_line; // file io var

// data in a row
real        dft_coef_flt32_re     = 0    ; // shortreal not supported in vivado
real        dft_coef_flt32_im     = 0    ; // shortreal not supported in vivado
reg  [31:0] dft_coef_flt32_re_hex = 32'b0;
reg  [31:0] dft_coef_flt32_im_hex = 32'b0;
reg  [63:0] dft_coef_flt64_re_hex = 64'b0;
reg  [63:0] dft_coef_flt64_im_hex = 64'b0;

initial begin : file_block
	file_in  = $fopen({DIR_SIM, FILE_NAME},"rb"); 
	//
	if(!file_in) begin
		$display("File Open Error!");
		$finish;
		// disable file_block; 
		end
		
	$display(">>>Reading File!");
	
	cnt_line = 0;
	while (!$feof(file_in)) begin
		@(posedge clk) 
		if (load) begin
			cnt_line = cnt_line + 1;
			ret_int = $fscanf(file_in,"%f %f  %h %h  %h %h", 
				dft_coef_flt32_re    , dft_coef_flt32_im    ,
				dft_coef_flt32_re_hex, dft_coef_flt32_im_hex,
				dft_coef_flt64_re_hex, dft_coef_flt64_im_hex);
			
			if (ret_int>0) begin 
				$display("dft: %6d(%0d)>  %f %f  %h %h  %h %h", 
					cnt_line, ret_int,
					dft_coef_flt32_re    , dft_coef_flt32_im    ,
					dft_coef_flt32_re_hex, dft_coef_flt32_im_hex,
					dft_coef_flt64_re_hex, dft_coef_flt64_im_hex);
				//
				end
				
			end
		end
		
	$fclose(file_in );
	
	//$finish;
end

// outputs 
assign o_dft_coef_flt32_re = dft_coef_flt32_re_hex;
assign o_dft_coef_flt32_im = dft_coef_flt32_im_hex;

endmodule
//}


////
module tb_conv_file__dft_coef_hex__coe_mif; //{
// read dft coef decimal+hexadecimal text file from py code 
// save as decimal text file (for valid)
// save as hexadecimal text file (for coe or so)
// save as unformmatted 0_1 text file (for mif)

// read : dft_coef_from__exp__129450_863__dec_hex.csv 
//   [re dec],[im dec], [re hex32],[im hex32], [re hex64],[im hex64]\n

integer file_in, file_out;

integer file_out_re_coe;
integer file_out_im_coe;
integer file_out_re_mif;
integer file_out_im_mif;

integer file_out_re_flt24_coe;
integer file_out_im_flt24_coe;
integer file_out_re_flt24_mif;
integer file_out_im_flt24_mif;

integer file_out_re_flt26_coe;
integer file_out_im_flt26_coe;
integer file_out_re_flt26_mif;
integer file_out_im_flt26_mif;

integer ret_int, cnt_line;
//reg [63:0]   r_data_dec_re  ; // NG  float --> reg
//reg [63:0]   r_data_dec_im  ; // NG  float --> reg
real         r_data_dec_re  ; // OK
real         r_data_dec_im  ; // OK
//shortreal      r_data_dec_re  ; // NG in  vivado
//shortreal      r_data_dec_im  ; // NG in  vivado
reg [31:0]   r_data_hex32_re;
reg [31:0]   r_data_hex32_im;
reg [63:0]   r_data_hex64_re;
reg [63:0]   r_data_hex64_im;
//
real         tmp_real;

parameter DIR_SIM     = "/media/sf_temp/dsn_cmu_git/xem7310_pll__CMU-CPU__work/xem7310_pll.srcs/sources_1/new/";
//parameter FILE_NAME = "dft_coef_from__exp__129450_863__dec_hex.txt"; 
parameter FILE_NAME   = "dft_coef_from__npfft__129450_863__dec_hex.txt"; 

// note :
//   file_out_re_coe  // for float32
//   file_out_im_coe  // for float32
//   file_out_re_mif  // for float32
//   file_out_im_mif  // for float32
//
//   file_out_re_flt24_coe  // for float24
//   file_out_im_flt24_coe  // for float24
//   file_out_re_flt24_mif  // for float24
//   file_out_im_flt24_mif  // for float24
//
//   file_out_re_flt26_coe  // for float26
//   file_out_im_flt26_coe  // for float26
//   file_out_re_flt26_mif  // for float26
//   file_out_im_flt26_mif  // for float26


initial begin : file_block
	file_in  = $fopen({DIR_SIM, FILE_NAME   },"rb"); 
	file_out = $fopen({DIR_SIM, "hh.out"    },"wb"); 
	//
	file_out_re_coe = $fopen({DIR_SIM, "hh_re.coe"},"wb"); // raw data for coe
	file_out_im_coe = $fopen({DIR_SIM, "hh_im.coe"},"wb"); // raw data for coe
	file_out_re_mif = $fopen({DIR_SIM, "hh_re.mif"},"wb"); // mif data for comparison
	file_out_im_mif = $fopen({DIR_SIM, "hh_im.mif"},"wb"); // mif data for comparison
	//
	file_out_re_flt24_coe = $fopen({DIR_SIM, "hh_re_flt24.coe"},"wb"); // raw data for coe
	file_out_im_flt24_coe = $fopen({DIR_SIM, "hh_im_flt24.coe"},"wb"); // raw data for coe
	file_out_re_flt24_mif = $fopen({DIR_SIM, "hh_re_flt24.mif"},"wb"); // mif data for comparison
	file_out_im_flt24_mif = $fopen({DIR_SIM, "hh_im_flt24.mif"},"wb"); // mif data for comparison
	//
	file_out_re_flt26_coe = $fopen({DIR_SIM, "hh_re_flt26.coe"},"wb"); // raw data for coe
	file_out_im_flt26_coe = $fopen({DIR_SIM, "hh_im_flt26.coe"},"wb"); // raw data for coe
	file_out_re_flt26_mif = $fopen({DIR_SIM, "hh_re_flt26.mif"},"wb"); // mif data for comparison
	file_out_im_flt26_mif = $fopen({DIR_SIM, "hh_im_flt26.mif"},"wb"); // mif data for comparison
	//
	if(!file_in || !file_out) begin
		$display("File Open Error!");
		$finish;
		// disable file_block; 
		end
		
	$display(">>>Reading File!");
	
	// coe header
	$fwrite(file_out_re_coe,"; dft coef real float32 from %s \n", FILE_NAME);
	$fwrite(file_out_im_coe,"; dft coef imag float32 from %s \n", FILE_NAME);
	$fwrite(file_out_re_coe,"memory_initialization_radix=16;\n");
	$fwrite(file_out_im_coe,"memory_initialization_radix=16;\n");
	$fwrite(file_out_re_coe,"memory_initialization_vector= \n" );
	$fwrite(file_out_im_coe,"memory_initialization_vector= \n" );
	//
	$fwrite(file_out_re_flt24_coe,"; dft coef real float24 from %s \n", FILE_NAME);
	$fwrite(file_out_im_flt24_coe,"; dft coef imag float24 from %s \n", FILE_NAME);
	$fwrite(file_out_re_flt24_coe,"memory_initialization_radix=16;\n");
	$fwrite(file_out_im_flt24_coe,"memory_initialization_radix=16;\n");
	$fwrite(file_out_re_flt24_coe,"memory_initialization_vector= \n" );
	$fwrite(file_out_im_flt24_coe,"memory_initialization_vector= \n" );
	//
	$fwrite(file_out_re_flt26_coe,"; dft coef real float26 from %s \n", FILE_NAME);
	$fwrite(file_out_im_flt26_coe,"; dft coef imag float26 from %s \n", FILE_NAME);
	$fwrite(file_out_re_flt26_coe,"memory_initialization_radix=16;\n");
	$fwrite(file_out_im_flt26_coe,"memory_initialization_radix=16;\n");
	$fwrite(file_out_re_flt26_coe,"memory_initialization_vector= \n" );
	$fwrite(file_out_im_flt26_coe,"memory_initialization_vector= \n" );

	cnt_line = 0;
	while (!$feof(file_in)) begin
		cnt_line = cnt_line + 1;
		//ret_int = $fscanf(file_in,"%g, %g", data_re_flt, data_im_flt);
		ret_int = $fscanf(file_in,"%g %g %h %h %h %h ", 
			r_data_dec_re  , 
			r_data_dec_im  , 
			r_data_hex32_re, 
			r_data_hex32_im, 
			r_data_hex64_re, 
			r_data_hex64_im);
		
		if (ret_int>0) begin 
			//$display("%d>  %g  %g ", cnt_line, data_re_flt, data_im_flt);
			$display("%06d>  %g %g  %h %h  %h %h", 
			//$display("%06d>  %g %g  %g %g  %g %g", 
				cnt_line, 
				r_data_dec_re  , 
				r_data_dec_im  , 
				r_data_hex32_re, 
				r_data_hex32_im, 
				r_data_hex64_re, 
				r_data_hex64_im);
			//
			//$cast(tmp_real, r_data_hex32_re); // NG not allowed in vivado
			//
			$display("-- %h %h %h %h -- %g ", 
				r_data_hex32_re[31:24], 
				r_data_hex32_re[23:16], 
				r_data_hex32_re[15: 8], 
				r_data_hex32_re[ 7: 0],
				r_data_dec_re         );
			//
			//$fwrite(file_out,"%23.18g %23.18g \n", data_re_flt, data_im_flt);
			$fwrite(file_out,"%23.18g %23.18g  %h %h  %h %h\n", 
				r_data_dec_re  , 
				r_data_dec_im  , 
				r_data_hex32_re, 
				r_data_hex32_im, 
				r_data_hex64_re, 
				r_data_hex64_im);
				
			// coe
			if (cnt_line==1) begin 
				$fwrite(file_out_re_coe,"%h", r_data_hex32_re);
				$fwrite(file_out_im_coe,"%h", r_data_hex32_im);

				$fwrite(file_out_re_flt24_coe,"%h", r_data_hex32_re[31:8]);
				$fwrite(file_out_im_flt24_coe,"%h", r_data_hex32_im[31:8]);

				$fwrite(file_out_re_flt26_coe,"%h", r_data_hex32_re[31:6]);
				$fwrite(file_out_im_flt26_coe,"%h", r_data_hex32_im[31:6]);
				end
			else begin
				$fwrite(file_out_re_coe,",\n%h", r_data_hex32_re);
				$fwrite(file_out_im_coe,",\n%h", r_data_hex32_im);

				$fwrite(file_out_re_flt24_coe,",\n%h", r_data_hex32_re[31:8]);
				$fwrite(file_out_im_flt24_coe,",\n%h", r_data_hex32_im[31:8]);

				$fwrite(file_out_re_flt26_coe,",\n%h", r_data_hex32_re[31:6]);
				$fwrite(file_out_im_flt26_coe,",\n%h", r_data_hex32_im[31:6]);
			end
			
			// mif
			$fwrite(file_out_re_mif,"%u\n", r_data_hex32_re);
			$fwrite(file_out_im_mif,"%u\n", r_data_hex32_im);
			//
			$fwrite(file_out_re_flt24_mif,"%u\n", r_data_hex32_re[31:8]);
			$fwrite(file_out_im_flt24_mif,"%u\n", r_data_hex32_im[31:8]);
			//
			$fwrite(file_out_re_flt26_mif,"%u\n", r_data_hex32_re[31:6]);
			$fwrite(file_out_im_flt26_mif,"%u\n", r_data_hex32_im[31:6]);
				
			end
		end
		
	// coe sentinel
	$fwrite(file_out_re_coe,";");
	$fwrite(file_out_im_coe,";");
	
	$fclose(file_in );
	$fclose(file_out);
	
	$fclose(file_out_re_coe);
	$fclose(file_out_im_coe);
	$fclose(file_out_re_mif);
	$fclose(file_out_im_mif);
	
	$fclose(file_out_re_flt24_coe);
	$fclose(file_out_im_flt24_coe);
	$fclose(file_out_re_flt24_mif);
	$fclose(file_out_im_flt24_mif);
	
	$fclose(file_out_re_flt26_coe);
	$fclose(file_out_im_flt26_coe);
	$fclose(file_out_re_flt26_mif);
	$fclose(file_out_im_flt26_mif);
	
	//$finish;
end


endmodule
//}


////
module tb_test_file_dft_coef; //{
// read dft coef decimal text file from py code 
// save as decimal text file again for test

//// read files
integer file_in, file_out, ret_int, cnt_line;
real   data_re_flt; // c double 64bit
real   data_im_flt; // c double 64bit

parameter DIR_SIM = "/media/sf_temp/dsn_cmu_git/xem7310_pll__CMU-CPU__work/xem7310_pll.srcs/sources_1/new/";

//reg [63:0] mem_coef_re[0:129450];
//reg [63:0] mem_coef_im[0:129450];

initial begin : file_block
	file_in  = $fopen({DIR_SIM, "fft_coef_from__exp__129450_863.csv"   },"rb"); 
	//file_in  = $fopen({DIR_SIM, "fft_coef_from__np_fft__129450_863.csv"},"rb"); 
	file_out = $fopen({DIR_SIM, "tt.out"},"wb"); 
	//$fwrite(file_out,"//>> test\n"); 
	//
	if(!file_in || !file_out) begin
		$display("File Open Error!");
		$finish;
		// disable file_block; 
		end
		
	$display(">>>Reading File!");
	
	cnt_line = 0;
	while (!$feof(file_in)) begin
		cnt_line = cnt_line + 1;
		ret_int = $fscanf(file_in,"%g, %g", data_re_flt, data_im_flt);
		
		if (ret_int>0) begin 
			//$display("> %f  %f ", data_re_flt, data_im_flt);
			//$display("> %e  %e ", data_re_flt, data_im_flt);
			$display("%d>  %g  %g ", cnt_line, data_re_flt, data_im_flt);
			//
			// note ... NG real --> reg
			//mem_coef_re[cnt_line-1] = data_re_flt; // store 64bit from real // NG bit convert
			//mem_coef_im[cnt_line-1] = data_im_flt; // store 64bit from real // NG bit convert
			//
			//$fwrite(file_out,"%d> %f %f\n", cnt_line, data_re_flt, data_im_flt);
			//$fwrite(file_out,"%06d> %23.15e %23.15e  %23.15e %23.15e \n", 
			//$fwrite(file_out,"%06d> %23.16g %23.16g  %h %h \n", 
			//	cnt_line, data_re_flt, data_im_flt, mem_coef_re[cnt_line-1], mem_coef_im[cnt_line-1]);
			//$fwrite(file_out,"%23.16g %23.16g \n", data_re_flt, data_im_flt);
			//$fwrite(file_out,"%23.17g %23.17g \n", data_re_flt, data_im_flt);
			//$fwrite(file_out,"%23.18g %23.18g  %h %h \n", data_re_flt, data_im_flt, data_re_flt, data_im_flt);
			$fwrite(file_out,"%23.18g %23.18g \n", data_re_flt, data_im_flt);
			end
		end
		
	$fclose(file_in );
	$fclose(file_out);
	
	//$finish;
end

endmodule 
//}


////
module tb_test_file_io; //{

parameter DIR_SIM = "/media/sf_temp/dsn_cmu_git/xem7310_pll__CMU-CPU__work/xem7310_pll.srcs/sources_1/new/";

integer i;
reg [7:0] memory [0:15]; // 8 bit memory with 16 entries
//shortreal memory [0:15]; // 8 bit memory with 16 entries // NG // not supported

initial begin
	$display(">>>>>> writememb vs writememh");
	for (i=0; i<16; i=i+1) begin
		memory[i] = i;
	end
	$writememb({DIR_SIM, "memory_binary.txt"}, memory);
	$writememh({DIR_SIM, "memory_hex.txt"   }, memory);
	
	//$finish;
end



endmodule 
//}


////
module tb_test; //{

//// clock and reset
reg clk_10M = 1'b0; // assume 10MHz or 100ns
	always
	#50 	clk_10M = ~clk_10M; // toggle every 50ns --> clock 100ns 

reg reset_n = 1'b0;
wire reset = ~reset_n;
//
/* 
reg clk_bus = 1'b0; //$$ 9.92ns for USB3.0	
	always
	#4.96 	clk_bus = ~clk_bus; // toggle every 4.96ns --> clock 9.92ns for USB3.0	 
//
reg clk_200M = 1'b0; // 200Mz
	always
	#2.5 	clk_200M = ~clk_200M; // toggle every 2.5ns --> clock 5ns 
	
reg clk_210M = 1'b0; // 210Mz
	always
	#2.38095238 	clk_210M = ~clk_210M; // toggle every 2.38095238 ns --> clock 4.76190476 ns 

reg clk_250M = 1'b0; // 250MHz
	always
	#2 	clk_250M = ~clk_250M; // toggle every 2ns --> clock 4ns 
	
reg clk_183M = 1'b0; // 183.3MHz
	always
	#2.72727273 clk_183M = ~clk_183M; // toggle every 2.72727273 ns --> clock 5.45454546 ns 

reg clk_92M = 1'b0; // 91.67MHz
	always
	#1.36363637 clk_92M = ~clk_92M; // toggle every 1.38888889 ns --> clock 2.72727273 ns 

reg clk_150M = 1'b0; // 150MHz
	always
	#3.33333333 clk_150M = ~clk_150M; // toggle every 3.33333333 ns --> clock 6.66666667 ns 

reg clk_75M = 1'b0; // 75MHz
	always
	#6.66666667 clk_75M = ~clk_75M; // toggle every 6.66666667 ns --> clock 13.3333333 ns 

reg clk_125M = 1'b0; // 125MHz
	always
	#4 	clk_125M = ~clk_125M; // toggle every 4ns --> clock 8ns 

reg clk_62p5M = 1'b0; // 62.5MHz
	always
	#8 	clk_62p5M = ~clk_62p5M; // toggle every 8ns --> clock 16ns  
*/

reg clk_144M = 1'b0; // 144MHz
//	always
//	#3.47222222 clk_144M = ~clk_144M; // toggle every 3.47222222 ns --> clock 6.94444444 ns 

reg clk_72M = 1'b0; // 72MHz
//	always
//	#6.94444444 clk_72M = ~clk_72M; // toggle every 6.94444444 ns --> clock 13.8888889 ns 

always begin
    #3.47222222;
    clk_144M = ~clk_144M; // toggle every 3.47222222 ns --> clock 6.94444444 ns
    clk_72M = ~clk_72M;
    #3.47222222 
    clk_144M = ~clk_144M; // toggle every 3.47222222 ns --> clock 6.94444444 ns
    end

reg clk_12M = 1'b0; // 12MHz
	always
	#41.6666667 clk_12M = ~clk_12M;  

//// test signals 
/* 
reg test_reset;
reg test_manual; // manual control for frame
reg test_frame;
reg [15:0] test_frame_adrs;
reg [ 5:0] test_frame_blck;
reg        test_frame_rdwr;
reg [ 2:0] test_frame_opmd;
reg [15:0] test_frame_numb;
//
reg [31:0] pattern_MISO;
//
reg [7:0] test_fifo_in_data; //
reg test_fifo_in_wr; //
reg test_fifo_out_rd; //
 */
//
reg test_strb_adrs;
reg test_strb_rd;
reg test_strb_wr;
reg [31:0] test_adrs;
reg [31:0] test_data;
reg [31:0] test_trig;
//

/* DUT */

// test io bus 
wire IO_addr_strobe      = test_strb_adrs;
wire [31:0] IO_address   = test_adrs;
wire [3:0] IO_byte_enable= 4'b0;
wire [31:0] IO_read_data ; //
wire IO_read_strobe      = test_strb_rd;
wire IO_ready            ;
wire IO_ready_ref        ;
wire [31:0] IO_write_data= test_data; 
wire IO_write_strobe     = test_strb_wr;
//
wire [31:0] w_port_wi_00_0; // control for master_spi_wz850_inst
wire [31:0] w_port_wi_01_0; // frame setup for master_spi_wz850_inst
wire [31:0] w_port_wo_20_0; // status for master_spi_wz850_inst
wire [31:0] w_port_wo_21_0; // not yet
//
wire w_ck_40; wire [31:0] w_port_ti_40; // 
wire w_ck_60; wire [31:0] w_port_to_60; // 
//
wire w_wr_80; wire [31:0] w_port_pi_80; // LAN fifo wr
wire w_wr_81; wire [31:0] w_port_pi_81; // not yet
wire w_rd_A0; wire [31:0] w_port_po_A0; // LAN fifo rd
wire w_rd_A1; wire [31:0] w_port_po_A1; // not yet
//
mcs_io_bridge_ext #(
	.XPAR_IOMODULE_IO_BASEADDR  (32'h_C000_0000),
	.MCS_IO_INST_OFFSET         (32'h_0000_0000),// instance offset
	.FPGA_IMAGE_ID              (32'h_ACAC_1414)  
) mcs_io_bridge_ext_inst0 (
	.clk(clk_72M), // assume clk3_out1_72M
	.reset_n(reset_n),
	// IO bus
	.i_IO_addr_strobe(IO_addr_strobe),    // input  wire IO_addr_strobe
	.i_IO_address(IO_address),            // input  wire [31 : 0] IO_address
	.i_IO_byte_enable(IO_byte_enable),    // input  wire [3 : 0] IO_byte_enable
	.o_IO_read_data(IO_read_data),        // output wire [31 : 0] IO_read_data
	.i_IO_read_strobe(IO_read_strobe),    // input  wire IO_read_strobe
	.o_IO_ready(IO_ready),                // output wire IO_ready
	.o_IO_ready_ref(IO_ready_ref),      // output wire IO_ready_ref
	.i_IO_write_data(IO_write_data),      // input  wire [31 : 0] IO_write_data
	.i_IO_write_strobe(IO_write_strobe),  // input  wire IO_write_strobe
	// IO port
	.o_port_wi_00(w_port_wi_00_0),          // output wire [31:0]
	.o_port_wi_01(w_port_wi_01_0),          // output wire [31:0]
	.i_port_wo_20(w_port_wo_20_0),          // input  wire [31:0]
	.i_port_wo_21(w_port_wo_21_0),          // input  wire [31:0]
	//
	.i_port_ck_40(w_ck_40),  .o_port_ti_40(w_port_ti_40), // input  wire i_ck_40, output wire [31:0]   o_port_ti_40 ,
	.i_port_ck_60(w_ck_60),  .i_port_to_60(w_port_to_60), // input  wire i_ck_60, input  wire [31:0]   i_port_to_60 ,
	//
	.o_port_wr_80(w_wr_80),  .o_port_pi_80(w_port_pi_80), // output wire o_wr_80, output wire [31:0]   o_port_pi_80 ,
	.o_port_wr_81(w_wr_81),  .o_port_pi_81(w_port_pi_81), // output wire o_wr_81, output wire [31:0]   o_port_pi_81 ,
	.o_port_rd_A0(w_rd_A0),  .i_port_po_A0(w_port_po_A0), // output wire o_rd_A0, input  wire [31:0]   i_port_po_A0 ,
	.o_port_rd_A1(w_rd_A1),  .i_port_po_A1(w_port_po_A1), // output wire o_rd_A1, input  wire [31:0]   i_port_po_A1 ,
	//
	.valid()
);
//

// test input 
assign  w_port_wo_20_0 = 32'h2020_2020;
assign  w_port_wo_21_0 = 32'h2121_2121;
assign  w_port_to_60   = test_trig; //
assign  w_port_po_A0   = 32'hA0A0_A0A0;
assign  w_port_po_A1   = 32'hA1A1_A1A1;
assign  w_ck_40        = clk_12M;
assign  w_ck_60        = clk_12M;

/*
//
wire w_trig_LAN_reset = test_reset | w_port_wi_00_0[0];
wire w_done_LAN_reset;
wire w_trig_SPI_frame = test_frame | w_port_wi_00_0[1];
wire w_done_SPI_frame;
wire w_FIFO_reset     = w_port_wi_00_0[2];
//
wire w_LAN_RSTn;
wire w_LAN_INTn;
wire w_LAN_SCSn;
wire w_LAN_SCLK;
wire w_LAN_MOSI;
wire w_LAN_MISO;
//
wire [15:0] w_frame_num_byte_data = (test_manual)? test_frame_numb : w_port_wi_00_0[31:16]; 
wire [15:0] w_frame_adrs          = (test_manual)? test_frame_adrs : w_port_wi_01_0[31:16];
wire [ 4:0] w_frame_ctrl_blck_sel = (test_manual)? test_frame_blck : w_port_wi_01_0[15:11]; // for Socket 1 TX Buffer
wire        w_frame_ctrl_rdwr_sel = (test_manual)? test_frame_rdwr : w_port_wi_01_0[10]   ; // 1 for write
wire [ 1:0] w_frame_ctrl_opmd_sel = (test_manual)? test_frame_opmd : w_port_wi_01_0[9:8]  ; // 00 for variable length
wire [ 7:0] w_frame_data_wr      ;
wire        w_frame_done_wr      ;
wire [ 7:0] w_frame_data_rd      ;
wire        w_frame_done_rd      ;
//
wire w_LAN_valid;
//
wire       w_test_fifo_in_wr      = (test_manual)? test_fifo_in_wr  : w_wr_80          ; //
wire [7:0] w_test_fifo_in_data    = (test_manual)? test_fifo_in_data: w_port_pi_80[7:0]; //
wire       w_test_fifo_out_rd     = (test_manual)? test_fifo_out_rd : w_rd_A0          ; //
wire [7:0] w_test_fifo_out_data;
//
assign w_port_po_A0 = w_test_fifo_out_data;
*/
/* 
// LAN control
master_spi_wz850 #(
	.TIME_RESET_WAIT_MS (1) // for fast sim
) master_spi_wz850_inst (
	.clk				(clk_144M), // assume clk3_out2_144M
	.reset_n			(reset_n),
	.clk_reset          (clk_12M), //12MHz
	//
	.i_trig_LAN_reset	(w_trig_LAN_reset),
	.o_done_LAN_reset	(w_done_LAN_reset), 
	.i_trig_SPI_frame	(w_trig_SPI_frame), 
	.o_done_SPI_frame	(w_done_SPI_frame), 
	//
	.o_LAN_RSTn			(w_LAN_RSTn),
	.o_LAN_INTn			(w_LAN_INTn),
	.o_LAN_SCSn			(w_LAN_SCSn),
	.o_LAN_SCLK			(w_LAN_SCLK),
	.o_LAN_MOSI			(w_LAN_MOSI),
	.i_LAN_MISO			(w_LAN_MISO),
	//
	.i_frame_adrs         	(w_frame_adrs         ),
	.i_frame_ctrl_blck_sel	(w_frame_ctrl_blck_sel),
	.i_frame_ctrl_rdwr_sel	(w_frame_ctrl_rdwr_sel),
	.i_frame_ctrl_opmd_sel	(w_frame_ctrl_opmd_sel),
	.i_frame_num_byte_data	(w_frame_num_byte_data),
	.i_frame_data_wr      	(w_frame_data_wr      ),
	.o_frame_done_wr		(w_frame_done_wr      ),
	.o_frame_data_rd      	(w_frame_data_rd      ),
	.o_frame_done_rd		(w_frame_done_rd      ),
	//
	.valid				(w_LAN_valid)		
);
//
assign w_port_wo_20_0 = {27'b0, 
	w_done_SPI_frame ,
	w_LAN_INTn ,
	w_LAN_SCSn ,
	w_LAN_RSTn ,
	w_done_LAN_reset};
// 
*/
/* 
// fifo test wr
// fifo_generator_3 
//   width "8-bit"
//   depth "16378 = 2^14"
//   standard read mode
// 
fifo_generator_3  LAN_fifo_wr_inst (
	.rst		(~reset_n | ~w_LAN_RSTn | w_FIFO_reset),  // input wire rst 
	.wr_clk		(clk_72M			),  // input wire wr_clk
	.wr_en		(w_test_fifo_in_wr	),  // input wire wr_en
	.din		(w_test_fifo_in_data),  // input wire [7 : 0] din
	.wr_ack		(   	),  // output wire wr_ack
	.overflow	(   	),  // output wire overflow
	.prog_full	(   	),  // set at 16378
	.full		(   	),  // output wire full
//	//	
	.rd_clk		(clk_72M			),  // input wire rd_clk
	.rd_en		(w_frame_done_wr&(w_frame_ctrl_rdwr_sel)	),  // input wire rd_en
	.dout		(w_frame_data_wr	),  // output wire [7 : 0] dout
	.valid		(   	),  // output wire valid
	.underflow	(   	),  // output wire underflow
	.prog_empty	(   	),  // set at 5
	.empty		(   	)   // output wire empty
);
// 

// fifo test rd
fifo_generator_3  LAN_fifo_rd_inst (
	.rst		(~reset_n | ~w_LAN_RSTn | w_FIFO_reset),  // input wire rst 
	.wr_clk		(clk_72M			),  // input wire wr_clk
	.wr_en		(w_frame_done_rd&(~w_frame_ctrl_rdwr_sel)	),  // input wire wr_en
	.din		(w_frame_data_rd	),  // input wire [7 : 0] din
	.wr_ack		(   	),  // output wire wr_ack
	.overflow	(   	),  // output wire overflow
	.prog_full	(   	),  // set at 16378
	.full		(   	),  // output wire full
//	//	
	.rd_clk		(clk_72M				),  // input wire rd_clk
	.rd_en		(w_test_fifo_out_rd		),  // input wire rd_en
	.dout		(w_test_fifo_out_data	),  // output wire [7 : 0] dout
	.valid		(   	),  // output wire valid
	.underflow	(   	),  // output wire underflow
	.prog_empty	(   	),  // set at 5
	.empty		(   	)   // output wire empty
);
//
 */

/* test signals */

// system reset 
initial begin : reset_n__gen
#0	reset_n 	= 1'b0;
#200;
	reset_n 	= 1'b1; 
#200;
end

// test sequence 
initial begin
#0	;
// init 
	test_strb_adrs	= 1'b0;
	test_strb_rd	= 1'b0;
	test_strb_wr	= 1'b0;
	test_adrs		= 32'b0;
	test_data		= 32'b0;
	test_trig		= 32'b0;
#0	;
// wait for system reset
$display(" Wait for rise of reset_n"); 
@(posedge reset_n)
#200;
//

// test IO bus 
#0;
$display(">> TEST IO BUS:"); 
// read FPGA_IMAGE_ID
#0;
MCS_IO_BUS_READ (32'h_C000_0F00);
#200;
// test reg 
MCS_IO_BUS_WRITE(32'h_C000_0F04,32'h_4321_ABCD);
#14
MCS_IO_BUS_READ (32'h_C000_0F04);
#200;
// setup masks 
//parameter ADRS_MASK_WI           = ADRS_BASE + 32'h_0000_0F10;
MCS_IO_BUS_WRITE(32'h_C000_0F10,32'h_FFFF_0000);
#14
MCS_IO_BUS_READ (32'h_C000_0F10);
#14
//parameter ADRS_MASK_WO           = ADRS_BASE + 32'h_0000_0F14;
MCS_IO_BUS_WRITE(32'h_C000_0F14,32'h_FF00_00FF);
#14
MCS_IO_BUS_READ (32'h_C000_0F14);
#14
//parameter ADRS_MASK_TI           = ADRS_BASE + 32'h_0000_0F18;
MCS_IO_BUS_WRITE(32'h_C000_0F18,32'h_F0F0_0F0F);
#14
MCS_IO_BUS_READ (32'h_C000_0F18);
#14
//parameter ADRS_MASK_TO           = ADRS_BASE + 32'h_0000_0F1C;
MCS_IO_BUS_WRITE(32'h_C000_0F1C,32'h_A5A5_5A5A);
#14
MCS_IO_BUS_READ (32'h_C000_0F1C);
#14
#200;
// test wi
MCS_WI_WRITE(32'h00, 32'h_AAAA_5555, 32'h_FFFF_0000); // offset, data, mask
MCS_WI_READ (32'h00); // OK if 32'h_AAAA_0000 on test_data
MCS_WI_WRITE(32'h00, 32'h_0000_0000, 32'h_FF00_0000); // offset, data, mask
MCS_WI_READ (32'h00); // OK if 32'h_00AA_0000 on test_data
MCS_WI_WRITE(32'h00, 32'h_0000_0000, 32'h_FFFF_FFFF); // offset, data, mask
#200;
// test wo
MCS_WO_READ(32'h20, 32'h00FF_0F0F);
MCS_WO_READ(32'h20, 32'hFFFF_FFFF);
#200;
// test ti
MCS_TI_WRITE(32'h40, 32'h_AAAA_5555, 32'h_FFFF_0000); // offset, data, mask
MCS_TI_READ (32'h40); // 
MCS_TI_WRITE(32'h40, 32'h_0100_0000, 32'h_FF00_0000); // offset, data, mask
MCS_TI_READ (32'h40); // 
MCS_TI_WRITE(32'h40, 32'h_0000_0000, 32'h_FFFF_FFFF); // offset, data, mask
#200;
// trig i_port_to_60
@(posedge w_ck_60)
test_trig = 32'hAA55_CC33;
@(posedge w_ck_60)
test_trig = 32'h0000_0000;
#200;
// test to
MCS_TO_READ(32'h60, 32'h0000_000F);
MCS_TO_READ(32'h60, 32'h0FF0_F000);
MCS_TO_READ(32'h60, 32'h00FF_0F0F);
MCS_TO_READ(32'h60, 32'hFFFF_FFFF);
#200;

///////////////////////
	$finish;

//// test seq 
// write SW_BUILD_ID
MCS_WI_WRITE(32'h00, 32'h_0000_1234, 32'h_FFFF_FFFF); // offset, data, mask
// read FPGA_IMAGE_ID
MCS_WO_READ(32'h20, 32'hFFFF_FFFF);
// write SW_BUILD_ID
MCS_WI_WRITE(32'h00, 32'h_0000_0000, 32'h_FFFF_FFFF); // offset, data, mask
// read FPGA_IMAGE_ID
MCS_WO_READ(32'h20, 32'hFFFF_FFFF);
///////////////////////
	$finish;
	
// trig LAN reset over IO bus 
$display(">>> trig LAN reset over IO bus"); 
MCS_IO_BUS_WRITE(32'h_C000_0000,32'h_0000_0001); // w_port_wi_00_0[0];
#200;
MCS_IO_BUS_WRITE(32'h_C000_0000,32'h_0000_0000); // w_port_wi_00_0[0];
#200;
// read w_done_LAN_reset 
MCS_IO_BUS_READ (32'h_C000_0200); // w_port_wo_20_0
#500_000; //500us = 500_000ns
// read w_done_LAN_reset 
MCS_IO_BUS_READ (32'h_C000_0200); // w_port_wo_20_0
#1000_000; //1ms = 1000us = 1000_000ns
// read w_done_LAN_reset 
MCS_IO_BUS_READ (32'h_C000_0200); // w_port_wo_20_0
#200;
///////////////////////
	$finish;
	
// write fifo data 
MCS_IO_BUS_WRITE(32'h_C000_0800,32'h_0000_00AB);
#14
MCS_IO_BUS_WRITE(32'h_C000_0800,32'h_0000_0012);
#14
MCS_IO_BUS_WRITE(32'h_C000_0800,32'h_0000_00CD);
#14
MCS_IO_BUS_WRITE(32'h_C000_0800,32'h_0000_0089);
#14
// set up write frame 
MCS_IO_BUS_WRITE(32'h_C000_0010,{8'b0, 16'h0040, 5'h06, 1'b1, 2'b0}); // wr frame setup
#14
MCS_IO_BUS_WRITE(32'h_C000_0020,{16'd0, 16'd04}); //
#14
// trig write frame over IO bus 
$display(">>> trig write frame over IO bus"); 
MCS_IO_BUS_WRITE(32'h_C000_0000,{16'd0, 14'h0, 1'b1, 1'b0}); //
#14
MCS_IO_BUS_WRITE(32'h_C000_0000,{16'd0, 14'h0, 1'b0, 1'b0}); //
#14
// read w_done_SPI_frame
MCS_IO_BUS_READ (32'h_C000_0200); // w_port_wo_20_0
#2000; //2us = 2000ns
MCS_IO_BUS_READ (32'h_C000_0200); // w_port_wo_20_0
#200;
///////////////////////
	$finish;
	
// set up read frame 
MCS_IO_BUS_WRITE(32'h_C000_0010,{8'b0, 16'h0040, 5'h06, 1'b0, 2'b0}); // rd frame setup
#14
MCS_IO_BUS_WRITE(32'h_C000_0020,{16'd0, 16'd04}); //
#14
// trig read frame over IO bus 
$display(">>> trig read frame over IO bus"); 
MCS_IO_BUS_WRITE(32'h_C000_0000,{16'd0, 14'h0, 1'b1, 1'b0}); //
#14
MCS_IO_BUS_WRITE(32'h_C000_0000,{16'd0, 14'h0, 1'b0, 1'b0}); //
#14
// read w_done_SPI_frame
MCS_IO_BUS_READ (32'h_C000_0200); // w_port_wo_20_0
#2000; //2us = 2000ns
MCS_IO_BUS_READ (32'h_C000_0200); // w_port_wo_20_0
#200;
// read fifo data
MCS_IO_BUS_READ (32'h_C000_0A00);
#14
MCS_IO_BUS_READ (32'h_C000_0A00);
#14
MCS_IO_BUS_READ (32'h_C000_0A00);
#14
MCS_IO_BUS_READ (32'h_C000_0A00);
#14
//
#200;
///////////////////////
	$finish;
//
end

/* 
// test_MISO
always @(negedge w_LAN_SCLK) begin : pattern_MISO__gen
	if (!reset_n) begin
		pattern_MISO <= 32'hAA55_CC33;
		end 
	else begin
		pattern_MISO <= {pattern_MISO[30:0],pattern_MISO[31]};
	end
end
//
assign w_LAN_MISO = pattern_MISO[31];
 */
 
// task IO bus read 
task MCS_IO_BUS_READ;
	input  [31:0] adrs;
	begin 
		@(posedge clk_72M);
		test_strb_adrs = 1'b1;
		test_adrs      = adrs; //
		test_strb_rd   = 1'b1;
		@(posedge clk_72M);
		test_strb_adrs = 1'b0;
		test_adrs      = 32'h0;
		test_strb_rd   = 1'b0;
		@(negedge clk_72M); // neg
		// read data 
		test_data      = IO_read_data; //
		@(negedge IO_ready); // neg
	end
endtask 

// task IO bus WRITE 
task MCS_IO_BUS_WRITE;
	input  [31:0] adrs;
	input  [31:0] data;
	begin 
		@(posedge clk_72M);
		test_strb_adrs = 1'b1;
		test_adrs      = adrs; //
		test_strb_wr   = 1'b1;
		test_data      = data; //
		@(posedge clk_72M);
		test_strb_adrs = 1'b0;
		test_adrs      = 32'h0;
		test_strb_wr   = 1'b0;
		test_data      = 32'h0; //
		@(negedge IO_ready); // neg
	end
endtask 

// task wi read 
task MCS_WI_READ;
	input  [31:0] offset;
	begin
	MCS_IO_BUS_READ(32'h_C000_0000+(offset<<4)); 
	#14;
	end
endtask 

// task wi write 
task MCS_WI_WRITE;
	input  [31:0] offset;
	input  [31:0] data;
	input  [31:0] mask;
	begin
	//parameter ADRS_MASK_WI           = ADRS_BASE + 32'h_0000_0F10;
	MCS_IO_BUS_WRITE(32'h_C000_0F10, mask);
	#14;
	MCS_IO_BUS_WRITE(32'h_C000_0000+(offset<<4), data); 
	#14;
	end
endtask 

// task wo20 read 
task MCS_WO_READ;
	input  [31:0] offset;
	input  [31:0] mask;
	begin
	//parameter ADRS_MASK_WO           = ADRS_BASE + 32'h_0000_0F14;
	MCS_IO_BUS_WRITE(32'h_C000_0F14, mask);
	#14;
	MCS_IO_BUS_READ(32'h_C000_0000+(offset<<4)); 
	#14;
	end
endtask 

// task wo20 write // NA

// task ti40 read 
task MCS_TI_READ;
	input  [31:0] offset;
	begin
	MCS_IO_BUS_READ(32'h_C000_0000+(offset<<4)); 
	#14;
	end
endtask 

// task ti40 write 
task MCS_TI_WRITE;
	input  [31:0] offset;
	input  [31:0] data;
	input  [31:0] mask;
	begin
	//parameter ADRS_MASK_TI           = ADRS_BASE + 32'h_0000_0F18;
	MCS_IO_BUS_WRITE(32'h_C000_0F18, mask);
	#14;
	MCS_IO_BUS_WRITE(32'h_C000_0000+(offset<<4), data); 
	#14;
	end
endtask 

// task to60 read 
task MCS_TO_READ;
	input  [31:0] offset;
	input  [31:0] mask;
	begin
	//parameter ADRS_MASK_TO           = ADRS_BASE + 32'h_0000_0F1C;
	MCS_IO_BUS_WRITE(32'h_C000_0F1C, mask);
	#14;
	MCS_IO_BUS_READ(32'h_C000_0000+(offset<<4)); 
	#14;
	end
endtask 

// task to60 write // NA


//initial begin
	//$dumpfile ("waveform.vcd"); 
	//$dumpvars; 
//end 
  
//initial  begin
	//$display("\t\t time,\t clk,\t reset_n,\t en"); 
	//$monitor("%d,\t%b,\t%b,\t%b,\t%d",$time,clk,reset_n,en); 
//end 

//initial begin
//#1000_000; // 1ms = 1000_000ns
//	$finish;
//end

endmodule
//}