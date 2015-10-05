// register definition
class ctrl_reg_c extends uvm_reg;
  
  rand uvm_reg_field address;
  rand uvm_reg_field op_code;
  rand uvm_reg_field data;
 
  `uvm_register_cb(ctrl_reg_c, uvm_reg_cbs)
  `uvm_set_super_type(ctrl_reg_c, uvm_reg)
  
  `uvm_object_utils(ctrl_reg_c)
  
  function new (string name = "unnamed-ctrl_reg_c" );
    // coverage is selected from uvm_coverage_model_e
    super.new(name, 32, build_coverage(UVM_CVR_FIELD_VALS));
  endfunction
  
  
  virtual function void build();
    
    // create + configure for each uvm_reg_field
    
    address = uvm_reg_field::type_id::create("address");
    address.configure(this, 8, 0, "RW", 0, 'hff, 1, 1, 1);
    
    op_code = uvm_reg_field::type_id::create("op_code");
    op_code.configure(this, 8, 8, "RW", 0, 'hff, 1, 1, 1);
    
    data = uvm_reg_field::type_id::create("data");
    data.configure(this, 16, 16, "RW", 0, 'hffff, 1, 1, 1);
    
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
    ctrl_reg = ctrl_reg_c::type_id::create(
      "ctrl_reg", , get_full_name());
    
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
  
  rand vip_register_file_c vip_rf;
  
  `uvm_object_utils(vip_reg_model_c)
  
  function new( string name = "vip_reg_model_c");
    super.new(name, UVM_NO_COVERAGE);
  endfunction
  
  virtual function void build();
        
    // create, configure register file
    vip_rf = vip_register_file_c::type_id::create(
      "vip_rf", , get_full_name());
    
    // parent, path
    vip_rf.configure(this, "");
    vip_rf.build();
    vip_rf.lock_model();
    
    // define register file address mappings
    default_map = create_map(
      "default_map", 0, 4, UVM_LITTLE_ENDIAN, 0);
    
    default_map.add_submap(vip_rf.default_map, 0);
    set_hdl_path_root("tb_top.dut");
    this.lock_model();
    default_map.set_check_on_read();
    
  endfunction
  
endclass

// base register sequence: gets the reg_model, raise/drop objection
class base_reg_seq extends uvm_sequence;
  
  vip_reg_model_c reg_model;
  
  `uvm_object_utils(base_reg_seq)
  
  function new (string name = "base_reg_seq");
    super.new(name);
  endfunction
  
  // simplified
  virtual function void get_model();
    uvm_object tmp_object;
    // this -> wrong... we are in a sequence! 
    //To access config_db we need to access the sequncer
    //if (uvm_config_db#(uvm_object)::get(this, "", "reg_model", tmp_object))
    if (uvm_config_db#(uvm_object)::get(
      get_sequencer(), "", "reg_model", tmp_object))
      begin
        $cast(reg_model, tmp_object);
      end
  endfunction
  
  virtual task pre_start();
    get_model();
  endtask
  
  virtual task pre_body();
  	// for the following to take effect the (base_vseq 1_seq) 
    // 1_seq.set_starting_phase() should be called 
    // prior to 1_seq.start(..)    
    uvm_phase starting_phase = get_starting_phase(); // uvm-1.2
    if (starting_phase != null)
      begin
        starting_phase.raise_objection(this, "Started vseq");
      end
  endtask
  
  virtual task post_body();
  	// for the following to take effect the (base_vseq 1_seq) 
    // 1_seq.set_starting_phase() should be called 
    // prior to 1_seq.start(..) 
    uvm_phase starting_phase = get_starting_phase(); // uvm-1.2
    if (starting_phase != null)
      begin
        starting_phase.drop_objection(this, "Completed vseq");
      end
  endtask
  
endclass
