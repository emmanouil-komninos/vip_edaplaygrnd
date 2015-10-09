// typedef of virtual sequence
typedef uvm_sequence #(uvm_sequence_item) uvm_virtual_sequence;



// sequence item class
class vip_base_seq_item extends uvm_sequence_item;
  
  // class members. Automation
  rand bit [7:0] op_code;
  rand bit [7:0] address;
  rand bit [15:0] data;
  
  `uvm_object_utils_begin(vip_base_seq_item)
  `uvm_field_int(op_code, UVM_DEFAULT)
  `uvm_field_int(address, UVM_DEFAULT)
  `uvm_field_int(data, UVM_DEFAULT)
  `uvm_object_utils_end
  
  function new (string name = "vip_base_seq_item");
    super.new(name);
  endfunction
  
endclass



// adapter class
class vip_reg_cbus_adapter extends uvm_reg_adapter;
  
  `uvm_object_utils(vip_reg_cbus_adapter)
  
  function new (string name = "vip_reg_cbus_adapter");
    super.new(name);
  endfunction

  virtual function uvm_sequence_item reg2bus(
    const ref uvm_reg_bus_op rw);
    
    vip_base_seq_item bus_item;
    bus_item = vip_base_seq_item::type_id::create("bus_item");
    
    bus_item.address = rw.data[23:16];
    bus_item.op_code = rw.data[31:24];
    bus_item.data = rw.data[15:0];
    
    return (bus_item);    
  endfunction
  
  virtual function void bus2reg(
    uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
    
    vip_base_seq_item incoming_bus_item;
    incoming_bus_item =
    vip_base_seq_item::type_id::create("incoming_bus_item");

    if(!$cast(incoming_bus_item, bus_item))
      begin
        `uvm_error($sformatf("%s", this.get_name()),
                   "Expecting vip_base_seq_item type")
        return;
      end
    
    rw.data[23:16] = incoming_bus_item.address;
    rw.data[31:24] = incoming_bus_item.op_code;
    rw.data[15:0] = incoming_bus_item.data;
    
  endfunction
endclass



// base sequence class
class vip_base_sequence extends uvm_sequence #(vip_base_seq_item);
  
  `uvm_object_utils(vip_base_sequence)
  
  function new (string name = "vip_base_sequence");
    super.new(name);
  endfunction
  
endclass



// configuration classes
class vip_agent_config extends uvm_object;
  vip_vif vif;
  function new (string name = "vip_agent_config");
    super.new(name);
  endfunction
endclass

class vip_env_config extends uvm_object;
  vip_vif vif;
  function new (string name = "vip_env_config");
    super.new(name);
  endfunction
endclass


// sequencer class
class vip_sequencer extends uvm_sequencer #(vip_base_seq_item);
  
  // macro for factory registeration and automation
  // of class members
  `uvm_component_utils(vip_sequencer)  
  
  function new (string name = "vip_sequencer", uvm_component parent);
    super.new(name, parent);
  endfunction
  
endclass


// reset monitor
class vip_reset_mon extends uvm_monitor;
  
  `uvm_component_utils(vip_reset_mon)
  
  vip_vif vif;
  
  function new (string name = "vip_reset_mon", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(!uvm_config_db#(vip_vif)::get(null,get_full_name(),"vif", vif))
      begin
        `uvm_error($sformatf("%s: connect_phase", this.get_name()),
                   "vip_vif get from config_db failed")
      end
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    fork
    //forever
      begin
        @(negedge vif.reset);
        `uvm_info($sformatf("%s", this.get_name()), "Reset dropped", UVM_LOW)
      end
    //forever
      begin
        @(posedge vif.reset);
        `uvm_info($sformatf("%s", this.get_name()), "Reset raised", UVM_LOW)
      end
    join_none
  endtask
endclass


// driver class
class vip_driver extends uvm_driver #(vip_base_seq_item);
  
  // configuration. Automation
  
  // class members. Automation
  
  // macro for factory registeration and automation
  // of class members
  `uvm_component_utils(vip_driver)
  
  // virtual if (or proxy)
  vip_vif vif;
  
  // analysis port for misc components
  
  // constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  // build phase
  
  // connect phase
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(!uvm_config_db#(vip_vif)::get(null,get_full_name(),"vif", vif))
      begin
        `uvm_error($sformatf("%s: connect_phase", this.get_name()),
                   "vip_vif get from config_db failed")
      end
  endfunction
  
  // run phase
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    if (vif == null)
      begin
        `uvm_fatal($sformatf("%s", this.get_name()), "Null virtual interface")
      end
    forever
      begin
        reset();
        fork
          @(posedge vif.reset) `uvm_info($sformatf("%s", this.get_name()), 
                                         "Posedge of reset received", UVM_LOW)
          begin
            forever
              begin           
                
                `uvm_info($sformatf("%s", this.get_name()), "", UVM_LOW);
                
                @(this.vif.vip_tb_mod.tb_ck iff(!this.vif.reset));
                
                `uvm_info($sformatf("%s", this.get_name()), 
                          "Waiting for next item", UVM_LOW)
                
                this.vif.vip_tb_mod.tb_ck.enable <= 0;
                
                seq_item_port.get_next_item(req);
                
                `uvm_info($sformatf("%s", this.get_name()), 
                          "New request received on driver", UVM_LOW)
                
                phase.raise_objection(
                  this, $sformatf("%s, %s objection: raised", 
                                  this.get_name(), phase.get_name()));
                get_and_drive();
                seq_item_port.item_done();                
                phase.drop_objection(
                  this, $sformatf("%s, %s objection: dropped", 
                                  this.get_name(), phase.get_name()));
              end
          end
        join_any;
        disable fork;
        if (req!= null)
          begin
            `uvm_info($sformatf("%s", this.get_name()), 
                      "Request is not null", UVM_LOW)              
          end
      end
  endtask
          
  // virtual functions to drive pins
  virtual task get_and_drive();
    `uvm_info($sformatf("%s",this.get_name()), "in get_and_drive", UVM_LOW)
    this.vif.vip_tb_mod.tb_ck.enable <= 1;
    this.vif.vip_tb_mod.tb_ck.op_code <= req.op_code;
    this.vif.vip_tb_mod.tb_ck.data <= req.data;
    this.vif.vip_tb_mod.tb_ck.address <= req.address;
  endtask
  
  virtual task reset();
    wait(this.vif.reset)
    `uvm_info($sformatf("%s",this.get_name()), "in reset", UVM_LOW)
    this.vif.vip_tb_mod.tb_ck.op_code <= 'hff;
    this.vif.vip_tb_mod.tb_ck.data <= 'hffff;
    this.vif.vip_tb_mod.tb_ck.address <= 'hff;
  endtask
endclass

// agent class
class vip_agent extends uvm_agent;

  // macro for factory registeration and automation
  // of class members
  `uvm_component_utils(vip_agent)  
  
  // configuration. No automation
  vip_agent_config m_config;
  
  // agent's components. No automation
  vip_driver driver;
  vip_sequencer seqr;
  vip_reset_mon reset_mon;
  
  // constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  // build phase
  virtual function void build_phase (uvm_phase phase);
    
    super.build_phase(phase);
    
    `uvm_info($sformatf("%s: build_phase", this.get_name()),
              "", UVM_LOW)
    
    if(!uvm_config_db#(vip_agent_config)::
       get(null, get_full_name(), "config", m_config))
      begin
        `uvm_error($sformatf("%s", this.get_name()), 
                   "agent_config does not exist in config db")
      end      
    
    uvm_config_db#(vip_vif)::set(this, "driver", "vif", m_config.vif);
    uvm_config_db#(vip_vif)::set(this, "reset_mon", "vif", m_config.vif);
    
    driver = vip_driver::type_id::create("driver", this);
    seqr = vip_sequencer::type_id::create("seqr", this);
    reset_mon = vip_reset_mon::type_id::create("reset_mon", this);
    
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
  
  // class members. Automation
  
  // macro for factory registeration and automation
  // of class members
  `uvm_component_utils(vip_env)
  
  // configuration. No automation
  vip_env_config m_config;
  
  // env's components. No automation
  vip_agent agent;
  vip_agent_config agent_config;
    
  // constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);      
  endfunction
  
  // build phase
  virtual function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(vip_env_config)::get(this, "", "config", m_config))
      begin
        `uvm_error(this.get_name(), "Config not found in db")      
      end
    agent_config = new("agent_config");
    if (!agent_config.randomize())
      begin
        `uvm_error(this.get_name(), 
                   $sformatf("Randomization of %S failed", agent_config.get_name()))
      end
    agent_config.vif = m_config.vif;
    uvm_config_db#(vip_agent_config)::set(this,"agent", "config", agent_config);
    agent = vip_agent::type_id::create("agent", this);
  endfunction
  
  // connect phase
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction
  
  // start of simulation
  function void start_of_simulation_phase(uvm_phase phase);
    check_config_usage();  
  endfunction
  
  // all dropped with drain time
  task all_dropped (uvm_objection objection, uvm_object source_obj, 
                    string description, int count);

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
