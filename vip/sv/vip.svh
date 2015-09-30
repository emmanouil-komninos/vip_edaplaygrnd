`ifndef VIP__SVH
`define VIP__SVH


// typedef of virtual sequence
typedef uvm_sequence #(uvm_sequence_item) uvm_virtual_sequence;



// sequence item class
class vip_base_seq_item extends uvm_sequence_item;
  
  // class members. Automation
  rand logic [7:0] op_code;
  rand bit [7:0] address;
  rand bit [31:0] data;
  
  `uvm_object_utils_begin(vip_base_seq_item)
  `uvm_field_int(op_code, UVM_DEFAULT)
  `uvm_field_int(address, UVM_DEFAULT)
  `uvm_field_int(data, UVM_DEFAULT)
  `uvm_object_utils_end
  
  function new (string name = "vip_base_seq_item");
    super.new(name);
  endfunction
  
endclass



// sequence classes
class vip_base_sequence extends uvm_sequence #(vip_base_seq_item);
  
  `uvm_object_utils(vip_base_sequence)
  
  function new (string name = "vip_base_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(10)
      begin
        `uvm_do_with(req, {req.op_code inside {[1:2]};})  
      end
  endtask

endclass



// configuration classes



// sequencer class
class vip_sequencer extends uvm_sequencer #(vip_base_seq_item);
  
  // macro for factory registeration and automation
  // of class members
  `uvm_component_utils(vip_sequencer)  
  
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
endclass



// virtual sequencer
class vip_base_vseqr extends uvm_virtual_sequencer;
  
  `uvm_component_utils(vip_base_vseqr)
  
  // sequencer handles
  vip_sequencer _seqr;
  
  function new (string name = "vip_base_vseqr", uvm_component parent);
    super.new(name, parent);
  endfunction

endclass



// driver class
class vip_driver extends uvm_driver #(vip_base_seq_item);
  
  // configuration. Automation
  
  // class members. Automation
  
  // macro for factory registeration and automation
  // of class members
  `uvm_component_utils(vip_driver)
  
  // protected virtual if (or proxy)
  protected vip_vif vif;
  
  // analysis port for misc components
  
  // constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  // build phase
  
  // connect phase
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);          
    
    if(!uvm_config_db#(vip_vif)::get(null,get_full_name(),"vip_vif", vif))
      begin
        `uvm_error($sformatf("%s: connect_phase", this.get_name()),
                   "vip_vif get from config_db failed")
      end
  endfunction
  
  // run phase
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever
      begin
        seq_item_port.get_next_item(req);
        
        
        if (req == null)
          begin
            `uvm_fatal($sformatf("%s", this.get_name()), "req is null")    
          end
        else
          req.print();
        
        phase.raise_objection(
          this, $sformatf("%s, %s objection: ", 
                          this.get_name(), phase.get_name(), "raised"));
        `uvm_info($sformatf("%s", this.get_name()), 
                  $sformatf("get_objection_count=%0d", 
                            phase.get_objection_count(this)), UVM_LOW)
        
        get_and_drive();
        seq_item_port.item_done();
        
        phase.drop_objection(
          this, $sformatf("%s, %s objection: ", 
                          this.get_name(), phase.get_name(), "dropped"));
        
      end
  endtask
        
  
  // virtual functions to drive pins
  virtual task get_and_drive();
    this.vif.vip_tb_mod.tb_ck.op_code <= req.op_code;
    this.vif.vip_tb_mod.tb_ck.data <= req.data;
    this.vif.vip_tb_mod.tb_ck.address <= req.address;
    @this.vif.vip_tb_mod.tb_ck;
  endtask
  
  
endclass




// agent class
class vip_agent extends uvm_agent;
  
  // configuration. Automation
  
  // macro for factory registeration and automation
  // of class members
  `uvm_component_utils(vip_agent)
  
  
  // agent's components. No automation
  vip_driver driver;
  vip_sequencer seqr;
  
  // constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  // build phase
  virtual function void build_phase (uvm_phase phase);
    
    super.build_phase(phase);
    
    `uvm_info($sformatf("%s: build_phase", this.get_name()),
              "", UVM_LOW)
    
    if(!uvm_config_db#(vip_vif)::
       exists(null, get_full_name(), "vip_vif"))
      begin
        `uvm_error($sformatf("%s", this.get_name()), 
                   "vip_vif does not exist in config db")
      end
    else
      begin
        `uvm_info($sformatf("%s", this.get_name()), 
                  "vip_vif exists in db", UVM_LOW)
      end        
    
    driver = vip_driver::type_id::create("driver", this);
    seqr = vip_sequencer::type_id::create("seqr", this);
  endfunction
  
  // connect phase
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info($sformatf("%s: connect_phase", this.get_name()),
              "", UVM_LOW)
    driver.seq_item_port.connect(seqr.seq_item_export);
  endfunction
  
endclass



// env class
class vip_env extends uvm_env;
  
  // configuration. Automation
  
  // class members. Automation
  
  // macro for factory registeration and automation
  // of class members
  `uvm_component_utils(vip_env)
  
  // env's components. No automation
  vip_agent agent;
    
  // constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);      
  endfunction
  
  // build phase
  virtual function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    agent = vip_agent::type_id::create("agent", this);
  endfunction
  
  // connect phase
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction
  
  // all dropped with drain time
  task all_dropped (uvm_objection objection, uvm_object source_obj, 
                    string description, int count);
    objection.print();
    if (objection == uvm_test_done)
      begin
        `uvm_info($sformatf("%s: all_dropped", this.get_name()), 
                  "objection == uvm_test_done",UVM_LOW)
        `uvm_info($sformatf("%s: all_dropped", this.get_name()), 
                  $sformatf("get_objection_count=%0d",
                            objection.get_objection_count(this)), UVM_LOW)
        `uvm_info($sformatf("%s: all_dropped", this.get_name()), 
                  $sformatf("get_objection_total=%0d", 
                            objection.get_objection_total), UVM_LOW) 
        //repeat(15);
      end
  endtask
  
endclass


`endif
