// sequence classes
class vip_simple_sequence extends vip_base_sequence;
  
  `uvm_object_utils(vip_simple_sequence)
  
  function new (string name = "vip_simple_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
    `uvm_info("VIP_SIMPLE_SEQUENCE", "Running", UVM_LOW)
    repeat(1)
      begin
        `uvm_do_with(req, {req.op_code inside {[1:2]};})  
      end
  endtask

endclass
