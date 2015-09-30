interface design_if (input bit clk);
  	
  logic [7:0] op_code;
  logic [15:0] address;
  logic [31:0] data;
    
  clocking tb_ck @(posedge clk);
    output op_code;
    output address;
    output data;
  endclocking
    
  modport vip_tb_mod (clocking tb_ck);
    
endinterface
