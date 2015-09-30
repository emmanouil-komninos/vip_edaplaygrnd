module _design (design_if _if);
  
  reg [31:0] data;
  
  reg [7:0] op_code;
  reg [7:0] address;
  
  reg [31:0] reg_data;
  reg [31:0] reg_array [7:0];
  
  always @(posedge _if.clk)
    begin
      address <= _if.address;
      op_code <= _if.op_code;
      data <= _if.data;
    end
  
  always @(op_code)
    begin
      
      case(op_code)
        1 : 
          begin
            reg_data <= data;
            $display("op_code is 1");
          end
        2 : 
          begin
            reg_data <= data>>1;
            $display("op_code is 2");
          end
        3 : 
          begin
            reg_data <= data<<1;
            $display("op_code is 3");
          end
        4 : 
          begin
            reg_data <= ~data;
            $display("op_code is 4");
          end
        default : 
          begin
            reg_data <= reg_data;
            $display("op_code is not 1");
          end
      endcase
    end

endmodule
            
