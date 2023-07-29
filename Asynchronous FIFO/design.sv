// module async_fifo_TB;

//   parameter DATA_WIDTH = 8;

//   wire [DATA_WIDTH-1:0] data_out;
//   wire full;
//   wire empty;
//   reg [DATA_WIDTH-1:0] data_in;
//   reg w_en, wclk, wrst_n;
//   reg r_en, rclk, rrst_n;

//   // Queue to push data_in
//   reg [DATA_WIDTH-1:0] wdata_q[$], wdata;

//   asynchronous_fifo as_fifo (wclk, wrst_n,rclk, rrst_n,w_en,r_en,data_in,data_out,full,empty);

//   always #10ns wclk = ~wclk;
//   always #35ns rclk = ~rclk;
  
//   initial begin
//     wclk = 1'b0; wrst_n = 1'b0;
//     w_en = 1'b0;
//     data_in = 0;
    
//     repeat(10) @(posedge wclk);
//     wrst_n = 1'b1;

//     repeat(2) begin
//       for (int i=0; i<30; i++) begin
//         @(posedge wclk iff !full);
//         w_en = (i%2 == 0)? 1'b1 : 1'b0;
//         if (w_en) begin
//           data_in = $urandom;
//           wdata_q.push_back(data_in);
//         end
//       end
//       #50;
//     end
//   end

//   initial begin
//     rclk = 1'b0; rrst_n = 1'b0;
//     r_en = 1'b0;

//     repeat(20) @(posedge rclk);
//     rrst_n = 1'b1;

//     repeat(2) begin
//       for (int i=0; i<30; i++) begin
//         @(posedge rclk iff !empty);
//         r_en = (i%2 == 0)? 1'b1 : 1'b0;
//         if (r_en) begin
//           wdata = wdata_q.pop_front();
//           if(data_out !== wdata) $error("Time = %0t: Comparison Failed: expected wr_data = %h, rd_data = %h", $time, wdata, data_out);
//           else $display("Time = %0t: Comparison Passed: wr_data = %h and rd_data = %h",$time, wdata, data_out);
//         end
//       end
//       #50;
//     end

//     $finish;
//   end
  
//   initial begin 
//     $dumpfile("dump.vcd"); $dumpvars;
//   end
// endmodule
module async_fifo_TB;

  parameter DATA_WIDTH = 8;
  // Define a parameter DATA_WIDTH with a default value of 8 to specify the width of data in the FIFO.

  wire [DATA_WIDTH-1:0] data_out;
  // Declare a wire data_out to capture the output data from the asynchronous FIFO.

  wire full;
  // Declare a wire full to capture the full status of the asynchronous FIFO.

  wire empty;
  // Declare a wire empty to capture the empty status of the asynchronous FIFO.

  reg [DATA_WIDTH-1:0] data_in;
  // Declare a register data_in to hold the input data to be written to the FIFO.

  reg w_en, wclk, wrst_n;
  // Declare registers w_en, wclk, and wrst_n to control the write operation of the FIFO.

  reg r_en, rclk, rrst_n;
  // Declare registers r_en, rclk, and rrst_n to control the read operation of the FIFO.

  // Queue to push data_in
  // Declare a queue wdata_q to store the data_in values that are being written into the FIFO.
  // The queue is used to verify the read data later.

  reg [DATA_WIDTH-1:0] wdata_q[$], wdata;
  // Declare registers wdata_q (a dynamic array) and wdata to store data values.

  asynchronous_fifo as_fifo (wclk, wrst_n, rclk, rrst_n, w_en, r_en, data_in, data_out, full, empty);
  // Instantiate the asynchronous_fifo module and connect its ports to the appropriate signals.

  always #10ns wclk = ~wclk;
  // Generate a clock signal for the write clock domain with a period of 20ns (50 MHz).

  always #35ns rclk = ~rclk;
  // Generate a clock signal for the read clock domain with a period of 70ns (14.2857 MHz).

  initial begin
    // This initial block is used for testbench setup and control.

    wclk = 1'b0; wrst_n = 1'b0;
    // Initialize the write clock and write reset signals to 0.

    w_en = 1'b0;
    // Set the write enable signal to 0.

    data_in = 0;
    // Initialize the input data to 0.

    repeat(10) @(posedge wclk);
    // Wait for 10 rising edges of the write clock to synchronize signals.

    wrst_n = 1'b1;
    // Release the write reset signal by setting it to 1.

    repeat(2) begin
      // Repeat the following block twice.

      for (int i=0; i<30; i++) begin
        // Execute the loop 30 times.

        @(posedge wclk iff !full);
        // Wait for a rising edge of the write clock but only if the FIFO is not full.

        w_en = (i%2 == 0)? 1'b1 : 1'b0;
        // Toggle the write enable signal w_en every other iteration.

        if (w_en) begin
          // If the write enable signal is asserted (write operation enabled):

          data_in = $urandom;
          // Generate a random value for data_in using system function $urandom.

          wdata_q.push_back(data_in);
          // Push the data_in value into the wdata_q queue for later verification.
        end
      end

      #50;
      // Wait for 50 time units between each iteration of the outer repeat loop.
      // This is to simulate some idle time between consecutive read operations.
    end
  end

  initial begin
    // This initial block is used for testbench verification of read operations.

    rclk = 1'b0; rrst_n = 1'b0;
    // Initialize the read clock and read reset signals to 0.

    r_en = 1'b0;
    // Set the read enable signal to 0.

    repeat(20) @(posedge rclk);
    // Wait for 20 rising edges of the read clock to synchronize signals.

    rrst_n = 1'b1;
    // Release the read reset signal by setting it to 1.

    repeat(2) begin
      // Repeat the following block twice.

      for (int i=0; i<30; i++) begin
        // Execute the loop 30 times.

        @(posedge rclk iff !empty);
        // Wait for a rising edge of the read clock but only if the FIFO is not empty.

        r_en = (i%2 == 0)? 1'b1 : 1'b0;
        // Toggle the read enable signal r_en every other iteration.

        if (r_en) begin
          // If the read enable signal is asserted (read operation enabled):

          wdata = wdata_q.pop_front();
          // Pop the front value from the wdata_q queue and store it in wdata.
          // This represents the data that should be read from the FIFO.

          if (data_out !== wdata)
            $error("Time = %0t: Comparison Failed: expected wr_data = %h, rd_data = %h", $time, wdata, data_out);
          else
            $display("Time = %0t: Comparison Passed: wr_data = %h and rd_data = %h", $time, wdata, data_out);
          // Compare the read data (data_out) with the expected value (wdata) and display the result.
        end
      end

      #50;
      // Wait for 50 time units between each iteration of the outer repeat loop.
      // This is to simulate some idle time between consecutive write operations.
    end

    $finish;
    // Finish the simulation.
  end

  initial begin
    // This initial block is used to enable VCD waveform dumping.

    $dumpfile("dump.vcd"); $dumpvars;
    // Specify the VCD (Value Change Dump) file to write waveform data and dump all variables.
  end
endmodule
