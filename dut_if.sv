interface design_if (input bit clk, input bit reset);
  bit enable;
  logic [7:0] op_code;
  logic [7:0] address;
  logic [15:0] data;
    
  clocking tb_ck @(posedge clk);
    output enable;
    output op_code;
    output address;
    output data;
  endclocking
    
  modport vip_tb_mod (clocking tb_ck);
    
endinterface
