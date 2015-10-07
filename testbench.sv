`include "uvm_macros.svh"
`include "dut_if.sv"
`include "vip_pkg.svh"
           
module tb_top;
  
  import uvm_pkg::*;
  import vip_test_pkg::*;
  
  reg clk = 0;
  reg reset;
  
  design_if dut_if(clk, reset);
  my_design dut(._if(dut_if)); 
  
  initial
    begin
      uvm_config_db#(vip_pkg::vip_vif)::set(null,"*.tb",
                                      "vip_vif", dut_if);       
    end

  initial
    begin
      run_test("vseq_simple_test");
      //run_test("simple_test");
    end
  
  initial
    begin
      reset = 1;
      #100 reset = ~reset;
    end
  
  initial
    begin
      forever #10 clk = ~clk;
    end
  
  initial 
    begin
      // Dump waves
      $dumpfile("dump.vcd");
      $dumpvars(1, tb_top);
      
      $dumpvars(1, tb_top.dut);
    end
  
endmodule  
