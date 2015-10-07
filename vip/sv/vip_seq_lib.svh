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

// register sequence
class vip_simple_reg_seq extends base_reg_seq;
  
  `uvm_object_utils(vip_simple_reg_seq)
  
  function new (string name = "vip_simple_reg_seq");
    super.new(name);
  endfunction
  // pre_body for init_done
  
  virtual task body();
    uvm_status_e status;
    bit [31:0] rd_val;
    string paths[$];
    `uvm_info("VIP_SIMPLE_REG_SEQ", "Running", UVM_LOW)

    reg_model.vip_rf.ctrl.print();
    
    // frontdoor write
    reg_model.vip_rf.ctrl.write(status, 'h0);
    
    #50ns;
    
    // backdoor write
    poke_reg(reg_model.vip_rf.ctrl, status, 'h12345);
    
    #50ns;
    
    // backdoor read
    peek_reg(reg_model.vip_rf.ctrl, status, rd_val );
    assert(rd_val == 'h12345);
    
    reg_model.vip_rf.ctrl.print();
    `uvm_info("VIP_SIMPLE_REG_SEQ", 
              $sformatf("Read value is %d", rd_val), UVM_LOW)
  endtask
endclass
