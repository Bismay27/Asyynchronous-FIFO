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
