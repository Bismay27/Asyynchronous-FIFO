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
