module _design (design_if _if);
  
 
  reg [31:0] ctrl; // [31:24] op_code [23:16] address [15:0] data
  
  reg [15:0] reg_array [7:0];
  reg [15:0] reg_data;
  
  always @(posedge _if.clk, _if.reset)
    begin
      if (_if.reset)
        begin
          ctrl[23:16] <= 'hff;
          ctrl[31:24] <= 'hff;
          ctrl[15:0] <= 'hffff;
        end
      else
        begin
          ctrl[23:16] <= _if.address;
          ctrl[31:24] <= _if.op_code;
          ctrl[15:0] <= _if.data;
        end
    end

endmodule
