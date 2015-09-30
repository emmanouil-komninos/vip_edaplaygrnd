// dut register models
class ctrl_reg extends uvm_reg;
  
  rand uvm_reg_field address;
  rand uvm_reg_field op_code;
  rand uvm_reg_field data;
 
  `uvm_register_cb(ctrl_reg, uvm_reg_cbs)
  `uvm_set_super_type(ctrl_reg, uvm_reg)
  
  `uvm_object_utils(ctrl_reg)
  
  function new (string name = "unnamed-ctrl_reg" );
    // covareg is selected from uvm_coverage_model_e
    super.new(name, 32, build_coverage(UVM_CVR_FIELD_VALS));
  endfunction
  
  
  virtual function void build();
    
    // create + configure for each uvm_reg_field
    
    address = uvm_reg_field::type_id::create("address");
    address.configure(this, 8, 0, "RW", 0, 0, 1, 1, 1);
    
    op_code = uvm_reg_field::type_id::create("op_code");
    op_code.configure(this, 8, 0, "RW", 0, 0, 1, 1, 1);
    
    data = uvm_reg_field::type_id::create("data");
    data.configure(this, 16, 0, "RW", 0, 0, 1, 1, 1);
    
  endfunction
  
endclass
