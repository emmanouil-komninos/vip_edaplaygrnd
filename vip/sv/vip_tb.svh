// base virtual sequencer
class base_vseqr extends uvm_virtual_sequencer;
  
  `uvm_component_utils(base_vseqr)
  
  // sequencer handles
  vip_sequencer seqr;
  
  function new (string name = "base_vseqr", uvm_component parent);
    super.new(name, parent);
  endfunction

endclass

// vip base virtual sequence using sequencer handles
class base_vseq extends uvm_virtual_sequence;
  
  `uvm_object_utils(base_vseq)
  
  // Declare p_sequencer
  `uvm_declare_p_sequencer(base_vseqr)
  
  function new (string name = "base_vseq");
    super.new(name);
  endfunction
  
  virtual task pre_body();
  	// for the following to take effect the (base_vseq 1_seq) 
    // 1_seq.set_starting_phase() should be called 
    // prior to 1_seq.start(..)    
    uvm_phase starting_phase = get_starting_phase(); // uvm-1.2
    if (starting_phase != null)
      begin
        if (this.get_automatic_phase_objection() == 0)
          begin
            starting_phase.raise_objection(this, "Started vseq");
            `uvm_info($sformatf("%s", this.get_name()), 
                      "Raised objection in pre_body", UVM_LOW)
          end
      end
  endtask
  
  virtual task post_body();
  	// for the following to take effect the (base_vseq 1_seq) 
    // 1_seq.set_starting_phase() should be called 
    // prior to 1_seq.start(..) 
    uvm_phase starting_phase = get_starting_phase(); // uvm-1.2
    if (starting_phase != null)
      begin
        if (this.get_automatic_phase_objection() == 0)
          begin
            starting_phase.drop_objection(this, "Completed vseq");
            `uvm_info($sformatf("%s", this.get_name()), 
                      "Dropped objection in post_body", UVM_LOW)
          end
      end
  endtask
   
endclass


// vip testbench. Contains IF UVCs, VSeqr, Module UVC, Register Files, Control Logic 

class vip_tb extends uvm_env;
    
  `uvm_component_utils(vip_tb)
	
  // env config object
  vip_env_config env_config;
  
  // Virtual sequencer
  base_vseqr vseqr;
  
  // TB's components. No automation
  vip_env env; // IF UVC
  vip_module_uvc mod_uvc; // Module UVC
  vip_reg_model_c reg_model; // DUT Register model
  
  // constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  // build phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    env_config = new("env_config");
    if (!env_config.randomize())
      begin
        `uvm_error(this.get_name(), 
                   $sformatf("Randomization of %S failed", env_config.get_name()))
      end
    
    check_vip_vif();
    uvm_config_db#(vip_env_config)::set(this,"env","config", env_config);
    
    // IF UVCs
    env = vip_env::type_id::create("env", this);
    
    // Module UVC
    mod_uvc = vip_module_uvc::type_id::create("mod_uvc", this);
    
    // Virtual sequencer
    vseqr = base_vseqr::type_id::create("vseqr", this);
    
    // Register model
    if (reg_model == null)
      begin
        uvm_reg::include_coverage("*", UVM_CVR_ALL);
        reg_model = vip_reg_model_c::type_id::create("reg_model");
        reg_model.build(); // Not build_phase -> reg model is an object
        reg_model.lock_model();
      end
    
    // set the reg_model for the rest of the TB
    
    // The following breaks auto_config and explicit get is needed
    //uvm_config_db#(vip_reg_model_c)::set(this, "*", "reg_model", reg_model);
    
    // The following allows for auto_config
    uvm_config_object::set(this, "*", "reg_model", reg_model);
  
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    // initialize the sequencer handles in virtual sequencer
    vseqr.seqr = this.env.agent.seqr;
    
    // set register model's sequencer and adapter
    // must be done prior to using any sequence based on uvm_reg_sequencer
    reg_model.default_map.set_sequencer(env.agent.seqr, mod_uvc.reg_cbus);
    
    //connect bus monitor to module uvc predictor.bus_in    
    
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    fork
      super.run_phase(phase);
      reset_reg_model();
    join
  endtask
  
  extern task reset_reg_model();
  extern function void check_vip_vif();
    
endclass
    
    task vip_tb::reset_reg_model();
      fork
        @(negedge this.env_config.vif.reset) 
        `uvm_info($sformatf("%s", this.get_name()), 
                  "Negedge of reset received", UVM_LOW)
        reg_model.reset();
      join
      
      //forever
        //begin
          //wait for top reset to become high
          //wait(vif.reset===1);
          //`uvm_info($sformatf(
            //"%s", this.get_name()), 
                    //"Resetting the register model", UVM_LOW)
          //reg_model.reset();
          //reg_model.vip_rf.print();
        //end
      
    endtask
    
    function void vip_tb::check_vip_vif();
      
      if(!uvm_config_db#(vip_vif)::
         get(null, get_full_name(), "vip_vif", this.env_config.vif))
        begin
          `uvm_error($sformatf("%s", this.get_name()), 
                     "vip_vif does not exist in config db")
        end
      else
        begin
          `uvm_info($sformatf("%s", this.get_name()), 
                    "vip_vif exists in db", UVM_LOW)
          if(this.env_config.vif == null)
            begin
              `uvm_error($sformatf("%s", this.get_name()), 
                         "vif is null")
            end
        end
    endfunction
