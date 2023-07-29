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
