// register definition
class ctrl_reg_c extends uvm_reg;
  
  rand uvm_reg_field address;
  rand uvm_reg_field op_code;
  rand uvm_reg_field data;
 
  `uvm_register_cb(ctrl_reg_c, uvm_reg_cbs)
  `uvm_set_super_type(ctrl_reg_c, uvm_reg)
  
  `uvm_object_utils(ctrl_reg_c)
  
  function new (string name = "unnamed-ctrl_reg_c" );
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


// register file definition
class vip_register_file_c extends uvm_reg_block;
  
  // register members
  rand ctrl_reg_c ctrl_reg;
  
  `uvm_object_utils(vip_register_file_c)
  
  function new (string name = "vip_register_file_c");
    super.new(name, UVM_NO_COVERAGE);
  endfunction
  
  virtual function void build();
    // create, configure, build each register
    ctrl_reg = ctrl_reg_c::type_id::create("ctrl_reg");
    
    // parent, reg_file parent, path
    ctrl_reg.configure(this, null, "ctrl");
    ctrl_reg.build();
    
    // define register address mappings
    default_map = create_map("default_map", 
                             0, 4, UVM_LITTLE_ENDIAN, 0);
    default_map.add_reg(ctrl_reg, 0, "RW"); // 0 offset from base
  endfunction
    
endclass


// register model definition
class vip_reg_model_c extends uvm_reg_block;
  
  vip_register_file_c vip_rf;
  
  `uvm_object_utils(vip_reg_model_c)
  
  function new( string name = "vip_register_model_c");
    super.new(name, UVM_NO_COVERAGE);
  endfunction
  
  virtual function void build();
    // create, configure register file
    vip_rf = vip_register_file_c::type_id::create("vip_rf");
    
    // parent, path
    vip_rf.configure(this, "regs");
    vip_rf.build();
    vip_rf.lock_model();
    
    // define register file address mappings
    default_map = create_map("default_map", 
                             0, 4, UVM_LITTLE_ENDIAN, 0);
    
    default_map.add_supmap(vip_rf.default_map, 0);
    default_map.set_check_on_read();
    
    set_hdl_path_root("tb_top.dut");
    this.lock_model();
    
  endfunction
  
endclass
  
