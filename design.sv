module my_design (design_if _if);
  
 
  reg [31:0] ctrl; // [31:24] op_code [23:16] address [15:0] data
    
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
          if (_if.enable)
            begin
              ctrl[23:16] <= _if.address;
              ctrl[31:24] <= _if.op_code;
              ctrl[15:0] <= _if.data;
            end
        end
    end
endmodule   
