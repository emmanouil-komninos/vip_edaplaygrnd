`include "uvm_macros.svh"
`include "dut_if.sv"
`include "vip_pkg.svh"
           
module tb_top;
  
  import uvm_pkg::*;
  import vip_test_pkg::*;
  
  reg clk = 0;
  reg reset;

  design_if dut_if(clk);
  _design dut(._if(dut_if)); 
  
  initial
    begin
      uvm_config_db#(vip_pkg::vip_vif)::set(null,"*",
                                      "vip_vif",dut_if);       
    end

  initial
    begin
      run_test("vseq_simple_test");
      //run_test("simple_test");
    end
  
  initial
    begin
      forever #10 clk = ~clk;
    end
  
  initial 
    begin
      // Dump waves
      $dumpfile("dump.vcd");
      $dumpvars(1);
    end
  
endmodule  
