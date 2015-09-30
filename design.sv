module _design (design_if _if);
  
 
  reg [31:0] ctrl; // [31:24] op_code [23:16] address [15:0] data
  
  reg [15:0] reg_array [7:0];
  reg [15:0] reg_data;
  
  always @(posedge _if.clk)
    begin
      ctrl[23:16] <= _if.address;
      ctrl[31:24] <= _if.op_code;
      ctrl[15:0] <= _if.data;
    end
  
  always @(ctrl)
    begin
      
      case(ctrl[31:24])
        1 : 
          begin
            reg_array[ctrl[23:16]] <= ctrl[15:0];
            reg_data <= ctrl[15:0];
            $display("op_code is 1");
          end
        2 : 
          begin
            reg_array[ctrl[23:16]] <= ctrl[15:0]>>1;
            reg_data <= ctrl[15:0]>>1;
            $display("op_code is 2");
          end
        3 : 
          begin
            reg_array[ctrl[23:16]] <= ctrl[15:0]<<1;
            reg_data <= ctrl[15:0]<<1;
            $display("op_code is 3");
          end
        4 : 
          begin
            reg_array[ctrl[23:16]] <= ~ctrl[15:0];
            reg_data <= ~ctrl[15:0];
            $display("op_code is 4");
          end
        default : 
          begin
            reg_array[ctrl[23:16]] <= reg_array[ctrl[23:16]];
            reg_data <= reg_data;
            $display("op_code is not 1");
          end
      endcase
    end

endmodule
            
