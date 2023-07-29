// `include "synchronizer.v"
// `include "wptr_handler.v"
// `include "rptr_handler.v"
// `include "fifo_mem.v"

// module asynchronous_fifo #(parameter DEPTH=8, DATA_WIDTH=8) (
//   input wclk, wrst_n,
//   input rclk, rrst_n,
//   input w_en, r_en,
//   input [DATA_WIDTH-1:0] data_in,
//   output reg [DATA_WIDTH-1:0] data_out,
//   output reg full, empty
// );
  
//   parameter PTR_WIDTH = $clog2(DEPTH);
 
//   reg [PTR_WIDTH:0] g_wptr_sync, g_rptr_sync;
//   reg [PTR_WIDTH:0] b_wptr, b_rptr;
//   reg [PTR_WIDTH:0] g_wptr, g_rptr;

//   wire [PTR_WIDTH-1:0] waddr, raddr;

//   synchronizer #(PTR_WIDTH) sync_wptr (rclk, rrst_n, g_wptr, g_wptr_sync); //write pointer to read clock domain
//   synchronizer #(PTR_WIDTH) sync_rptr (wclk, wrst_n, g_rptr, g_rptr_sync); //read pointer to write clock domain 
  
//   wptr_handler #(PTR_WIDTH) wptr_h(wclk, wrst_n, w_en,g_rptr_sync,b_wptr,g_wptr,full);
//   rptr_handler #(PTR_WIDTH) rptr_h(rclk, rrst_n, r_en,g_wptr_sync,b_rptr,g_rptr,empty);
//   fifo_mem fifom(wclk, w_en, rclk, r_en,b_wptr, b_rptr, data_in,full,empty, data_out);

// endmodule
`include "synchronizer.v"
`include "wptr_handler.v"
`include "rptr_handler.v"
`include "fifo_mem.v"
// These are preprocessor directives (`include) used to include the specified Verilog source files.
// The included files likely contain other Verilog modules or code used in this module.

module asynchronous_fifo #(parameter DEPTH=8, DATA_WIDTH=8) (
  input wclk, wrst_n,
  input rclk, rrst_n,
  input w_en, r_en,
  input [DATA_WIDTH-1:0] data_in,
  output reg [DATA_WIDTH-1:0] data_out,
  output reg full, empty
);
// Definition of the asynchronous_fifo module.
// It is a FIFO (First-In-First-Out) memory with asynchronous read and write ports.
// It has parameters DEPTH (depth of the FIFO) and DATA_WIDTH (width of data stored in the FIFO).

  parameter PTR_WIDTH = $clog2(DEPTH);
  // Calculate PTR_WIDTH as the minimum number of bits required to represent DEPTH in binary.

  reg [PTR_WIDTH:0] g_wptr_sync, g_rptr_sync;
  // Declare registers for storing synchronized write and read pointers.

  reg [PTR_WIDTH:0] b_wptr, b_rptr;
  // Declare registers for storing delayed write and read pointers.

  reg [PTR_WIDTH:0] g_wptr, g_rptr;
  // Declare registers for storing write and read pointers.

  wire [PTR_WIDTH-1:0] waddr, raddr;
  // Declare wires for the write address (waddr) and read address (raddr).

  synchronizer #(PTR_WIDTH) sync_wptr (rclk, rrst_n, g_wptr, g_wptr_sync);
  // Instantiate the synchronizer module to synchronize the write pointer (g_wptr) from read clock domain to the write clock domain.
  // The synchronized write pointer is stored in g_wptr_sync.

  synchronizer #(PTR_WIDTH) sync_rptr (wclk, wrst_n, g_rptr, g_rptr_sync);
  // Instantiate the synchronizer module to synchronize the read pointer (g_rptr) from write clock domain to the read clock domain.
  // The synchronized read pointer is stored in g_rptr_sync.

  wptr_handler #(PTR_WIDTH) wptr_h(wclk, wrst_n, w_en,g_rptr_sync,b_wptr,g_wptr,full);
  // Instantiate the write pointer handler module to manage the write pointer's behavior.
  // It handles the write pointer's increment, and its value is temporarily delayed by one cycle (stored in b_wptr).
  // The current write pointer is in g_wptr, and full is an output indicating if the FIFO is full.

  rptr_handler #(PTR_WIDTH) rptr_h(rclk, rrst_n, r_en,g_wptr_sync,b_rptr,g_rptr,empty);
  // Instantiate the read pointer handler module to manage the read pointer's behavior.
  // It handles the read pointer's increment, and its value is temporarily delayed by one cycle (stored in b_rptr).
  // The current read pointer is in g_rptr, and empty is an output indicating if the FIFO is empty.

  fifo_mem fifom(wclk, w_en, rclk, r_en,b_wptr, b_rptr, data_in,full,empty, data_out);
  // Instantiate the FIFO memory module.
  // It stores and retrieves data in the FIFO based on the write and read pointers.
  // The FIFO memory is accessed during write (w_en) and read (r_en) operations.
  // The full and empty signals indicate whether the FIFO is full or empty, respectively.
  // The input data is data_in, and the output data is data_out.

endmodule
//////////////////////////////////////////////////////////////////////////////////
// module fifo_mem #(parameter DEPTH=8, DATA_WIDTH=8, PTR_WIDTH=3) (
//   input wclk, w_en, rclk, r_en,
//   input [PTR_WIDTH:0] b_wptr, b_rptr,
//   input [DATA_WIDTH-1:0] data_in,
//   input full, empty,
//   output reg [DATA_WIDTH-1:0] data_out
// );
//   reg [DATA_WIDTH-1:0] fifo[0:DEPTH-1];
  
//   always@(posedge wclk) begin
//     if(w_en & !full) begin
//       fifo[b_wptr[PTR_WIDTH-1:0]] <= data_in;
//     end
//   end
 
//   assign data_out = fifo[b_rptr[PTR_WIDTH-1:0]];
// endmodule
module fifo_mem #(parameter DEPTH=8, DATA_WIDTH=8, PTR_WIDTH=3) (
  input wclk, w_en, rclk, r_en,
  input [PTR_WIDTH:0] b_wptr, b_rptr,
  input [DATA_WIDTH-1:0] data_in,
  input full, empty,
  output reg [DATA_WIDTH-1:0] data_out
);
// Definition of the fifo_mem module.
// This module implements the memory (FIFO) functionality of an asynchronous FIFO.

  reg [DATA_WIDTH-1:0] fifo[0:DEPTH-1];
  // Declare an array of registers 'fifo' to represent the memory storage of the FIFO.
  // The array has 'DEPTH' number of elements, and each element is 'DATA_WIDTH' bits wide.

  always@(posedge wclk) begin
    // This is a synchronous always block sensitive to the positive edge of the 'wclk' signal.
    // The block executes whenever there is a rising edge of the 'wclk' signal.

    if (w_en & !full) begin
      // Check if both the write enable signal 'w_en' and the 'full' signal are not asserted.
      // This condition ensures that data can be written into the FIFO only when it is not full.

      fifo[b_wptr[PTR_WIDTH-1:0]] <= data_in;
      // Write the 'data_in' to the FIFO at the index specified by the 'b_wptr'.
      // The 'b_wptr' is the delayed write pointer, indicating the write location in the FIFO.
      // The write operation occurs only when the FIFO is not full ('full' signal is not asserted).
    end
  end

  assign data_out = fifo[b_rptr[PTR_WIDTH-1:0]];
  // Assign the data from the FIFO to 'data_out' based on the read pointer 'b_rptr'.
  // The 'b_rptr' is the delayed read pointer, indicating the read location in the FIFO.
endmodule
// module rptr_handler #(parameter PTR_WIDTH=3) (
//   input rclk, rrst_n, r_en,
//   input [PTR_WIDTH:0] g_wptr_sync,
//   output reg [PTR_WIDTH:0] b_rptr, g_rptr,
//   output reg empty
// );

//   reg [PTR_WIDTH:0] b_rptr_next;
//   reg [PTR_WIDTH:0] g_rptr_next;

//   assign b_rptr_next = b_rptr+(r_en & !empty);
//   assign g_rptr_next = (b_rptr_next >>1)^b_rptr_next;
//   assign rempty = (g_wptr_sync == g_rptr_next);
  
//   always@(posedge rclk or negedge rrst_n) begin
//     if(!rrst_n) begin
//       b_rptr <= 0;
//       g_rptr <= 0;
//     end
//     else begin
//       b_rptr <= b_rptr_next;
//       g_rptr <= g_rptr_next;
//     end
//   end
  
//   always@(posedge rclk or negedge rrst_n) begin
//     if(!rrst_n) empty <= 1;
//     else        empty <= rempty;
//   end
// endmodule
module rptr_handler #(parameter PTR_WIDTH=3) (
  input rclk, rrst_n, r_en,
  input [PTR_WIDTH:0] g_wptr_sync,
  output reg [PTR_WIDTH:0] b_rptr, g_rptr,
  output reg empty
);
// Definition of the rptr_handler module.
// This module handles the read pointer behavior in an asynchronous FIFO.

  reg [PTR_WIDTH:0] b_rptr_next;
  reg [PTR_WIDTH:0] g_rptr_next;
  // Declare registers for the next values of the read pointers.

  assign b_rptr_next = b_rptr + (r_en & !empty);
  // Calculate the next value of the delayed read pointer (b_rptr_next).
  // The read pointer advances when read enable (r_en) is asserted, and the FIFO is not empty.

  assign g_rptr_next = (b_rptr_next >> 1) ^ b_rptr_next;
  // Calculate the next value of the global read pointer (g_rptr_next).
  // The global read pointer is used for synchronization with the write clock domain.
  // It implements a gray counter for more robust synchronization.

  assign rempty = (g_wptr_sync == g_rptr_next);
  // Determine whether the FIFO is empty in the read clock domain by comparing
  // the synchronized write pointer (g_wptr_sync) with the next global read pointer (g_rptr_next).

  always@(posedge rclk or negedge rrst_n) begin
    // This is a synchronous always block sensitive to the positive edge of 'rclk'
    // and the negative edge of 'rrst_n' (active-low reset).

    if (!rrst_n) begin
      // Check if the reset signal 'rrst_n' is low (active-low reset).

      b_rptr <= 0;
      // If the reset signal is asserted, reset the delayed read pointer 'b_rptr' to 0.

      g_rptr <= 0;
      // Also, reset the global read pointer 'g_rptr' to 0 during the reset period.
    end
    else begin
      // If the reset signal 'rrst_n' is not asserted (high), proceed with normal operation.

      b_rptr <= b_rptr_next;
      // Update the delayed read pointer 'b_rptr' with its next value.

      g_rptr <= g_rptr_next;
      // Update the global read pointer 'g_rptr' with its next value.
    end
  end
  
  always@(posedge rclk or negedge rrst_n) begin
    // This is another synchronous always block sensitive to the positive edge of 'rclk'
    // and the negative edge of 'rrst_n' (active-low reset).

    if (!rrst_n)
      empty <= 1;
    // If the reset signal 'rrst_n' is asserted, set the 'empty' signal to 1 (indicating the FIFO is empty).
    else
      empty <= rempty;
    // Otherwise, update the 'empty' signal based on the 'rempty' signal, indicating whether the FIFO is empty.
  end
endmodule
// module synchronizer #(parameter WIDTH=3) (input clk, rst_n, [WIDTH:0] d_in, output reg [WIDTH:0] d_out);
//   reg [WIDTH:0] q1;
//   always@(posedge clk) begin
//     if(!rst_n) begin
//       q1 <= 0;
//       d_out <= 0;
//     end
//     else begin
//       q1 <= d_in;
//       d_out <= q1;
//     end
//   end
// endmodule

module synchronizer #(parameter WIDTH=3) (input clk, rst_n, [WIDTH:0] d_in, output reg [WIDTH:0] d_out);
    // The module has four ports: clk, rst_n, d_in (an array of WIDTH+1 bits), and d_out (an array of WIDTH+1 bits).

  reg [WIDTH:0] q1; 
  // Declare a register "q1" of WIDTH+1 bits to store the synchronized input data.

  always@(posedge clk) begin
    // This is a synchronous always block sensitive to the positive edge of the "clk" signal.
    // The block executes whenever there is a rising edge of the "clk" signal.

    if(!rst_n) begin
      // Check if the reset signal "rst_n" is low (active low reset).

      q1 <= 0;
      // If the reset signal is asserted, set the register "q1" to 0 (reset the register).

      d_out <= 0;
      // Also, set the output "d_out" to 0 to ensure that the output is zero during the reset period.
    end
    else begin
      // If the reset signal "rst_n" is not asserted (high), proceed with normal operation.

      q1 <= d_in;
      // Assign the input data "d_in" to the register "q1" on the rising edge of the clock.
      // This is the synchronization step, capturing the input data in a register to avoid metastability issues.

      d_out <= q1;
      // Assign the value of the register "q1" to the output "d_out".
      // This makes sure that the output is synchronized with the input.
    end
  end
endmodule
// module wptr_handler #(parameter PTR_WIDTH=3) (
//   input wclk, wrst_n, w_en,
//   input [PTR_WIDTH:0] g_rptr_sync,
//   output reg [PTR_WIDTH:0] b_wptr, g_wptr,
//   output reg full
// );

//   reg [PTR_WIDTH:0] b_wptr_next;
//   reg [PTR_WIDTH:0] g_wptr_next;
   
//   reg wrap_around;
//   wire wfull;
  
//   assign b_wptr_next = b_wptr+(w_en & !full);
//   assign g_wptr_next = (b_wptr_next >>1)^b_wptr_next;
  
//   always@(posedge wclk or negedge wrst_n) begin
//     if(!wrst_n) begin
//       b_wptr <= 0; // set default value
//       g_wptr <= 0;
//     end
//     else begin
//       b_wptr <= b_wptr_next; // incr binary write pointer
//       g_wptr <= g_wptr_next; // incr gray write pointer
//     end
//   end
  
//   always@(posedge wclk or negedge wrst_n) begin
//     if(!wrst_n) full <= 0;
//     else        full <= wfull;
//   end

//   //assign wrap_around = (g_wptr_next) ^ g_rptr_sync[PTR_WIDTH]; // To check MSB of write and read pointers are different
//   //assign wfull = wrap_around & (g_wptr_next[PTR_WIDTH-1] ^ g_rptr_sync[PTR_WIDTH-1]) & (g_wptr_next[PTR_WIDTH-2:0] == g_rptr_sync[PTR_WIDTH-2:0]);
//   assign wfull = (g_wptr_next == {~g_rptr_sync[PTR_WIDTH:PTR_WIDTH-1], g_rptr_sync[PTR_WIDTH-2:0]});

// endmodule
module wptr_handler #(parameter PTR_WIDTH=3) (
  input wclk, wrst_n, w_en,
  input [PTR_WIDTH:0] g_rptr_sync,
  output reg [PTR_WIDTH:0] b_wptr, g_wptr,
  output reg full
);
// Definition of the wptr_handler module.
// This module handles the write pointer behavior in an asynchronous FIFO.

  reg [PTR_WIDTH:0] b_wptr_next;
  reg [PTR_WIDTH:0] g_wptr_next;
  // Declare registers for the next values of the write pointers.

  reg wrap_around;
  // Declare a register to represent the wrap-around condition of the write pointer.

  wire wfull;
  // Declare a wire to indicate if the FIFO is full.

  assign b_wptr_next = b_wptr + (w_en & !full);
  // Calculate the next value of the delayed write pointer (b_wptr_next).
  // The write pointer advances when write enable (w_en) is asserted, and the FIFO is not full.

  assign g_wptr_next = (b_wptr_next >> 1) ^ b_wptr_next;
  // Calculate the next value of the global write pointer (g_wptr_next).
  // The global write pointer is used for synchronization with the read clock domain.
  // It implements a gray counter for more robust synchronization.

  always@(posedge wclk or negedge wrst_n) begin
    // This is a synchronous always block sensitive to the positive edge of 'wclk'
    // and the negative edge of 'wrst_n' (active-low reset).

    if (!wrst_n) begin
      // Check if the reset signal 'wrst_n' is low (active-low reset).

      b_wptr <= 0; // set default value
      // If the reset signal is asserted, reset the delayed write pointer 'b_wptr' to 0.

      g_wptr <= 0;
      // Also, reset the global write pointer 'g_wptr' to 0 during the reset period.
    end
    else begin
      // If the reset signal 'wrst_n' is not asserted (high), proceed with normal operation.

      b_wptr <= b_wptr_next;
      // Update the delayed write pointer 'b_wptr' with its next value.

      g_wptr <= g_wptr_next;
      // Update the global write pointer 'g_wptr' with its next value.
    end
  end

  always@(posedge wclk or negedge wrst_n) begin
    // This is another synchronous always block sensitive to the positive edge of 'wclk'
    // and the negative edge of 'wrst_n' (active-low reset).

    if (!wrst_n)
      full <= 0;
    // If the reset signal 'wrst_n' is asserted, set the 'full' signal to 0 (indicating the FIFO is not full).
    else
      full <= wfull;
    // Otherwise, update the 'full' signal based on the 'wfull' signal, indicating whether the FIFO is full.
  end

  // The following assign statement checks for the FIFO full condition based on the difference
  // between the global write pointer (g_wptr_next) and the synchronized read pointer (g_rptr_sync).

  // assign wrap_around = (g_wptr_next) ^ g_rptr_sync[PTR_WIDTH];
  // The above statement determines if the MSB of the write and read pointers are different,
  // indicating a wrap-around condition in the circular FIFO buffer.

  // assign wfull = wrap_around & (g_wptr_next[PTR_WIDTH-1] ^ g_rptr_sync[PTR_WIDTH-1]) & (g_wptr_next[PTR_WIDTH-2:0] == g_rptr_sync[PTR_WIDTH-2:0]);
  // The above statement checks for the FIFO full condition based on the wrap-around condition and the
  // difference in the second most significant bit between the write and read pointers.

  assign wfull = (g_wptr_next == {~g_rptr_sync[PTR_WIDTH:PTR_WIDTH-1], g_rptr_sync[PTR_WIDTH-2:0]});
  // The above statement uses bitwise operations to check if the FIFO is full.
  // It compares the global write pointer (g_wptr_next) with a modified version of the synchronized read pointer (g_rptr_sync).
  // The modification involves inverting the most significant bits of g_rptr_sync and leaving the rest unchanged.
  // If g_wptr_next is equal to the modified g_rptr_sync, then the FIFO is considered full.

endmodule
