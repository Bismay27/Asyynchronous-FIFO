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
