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
        starting_phase.raise_objection(
          this, "Started vseq");
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


// vip testbench. Contains IF UVCs, VSeqr, Module UVC, Register Files, Control Logic 

class vip_tb extends uvm_env;
    
  `uvm_component_utils(vip_tb)

  // protected virtual if or if proxy. No automation
  vip_vif vif;
  
  // virtual sequencer
  base_vseqr vseqr;
  
  // tb's components. No automation
  vip_env env;

  // constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  // build phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
        
    check_vip_vif();
    uvm_config_db#(vip_vif)::set(this,"*","vip_vif", vif);
    
    env = vip_env::type_id::create("env", this);
    
    vseqr = base_vseqr::type_id::create("vseqr", this);
    
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    // initialize the sequencer handles
    vseqr.seqr = this.env.agent.seqr;
    
  endfunction
  
  extern function void check_vip_vif();
    
endclass
    
    function void vip_tb::check_vip_vif();
      
      if(!uvm_config_db#(vip_vif)::
         get(null, get_full_name(), "vip_vif", this.vif))
        begin
          `uvm_error($sformatf("%s", this.get_name()), 
                     "vip_vif does not exist in config db")
        end
      else
        begin
          `uvm_info($sformatf("%s", this.get_name()), 
                    "vip_vif exists in db", UVM_LOW)
          if(this.vif == null)
            begin
              `uvm_error($sformatf("%s", this.get_name()), 
                         "vif is null")
            end
        end
    endfunction
