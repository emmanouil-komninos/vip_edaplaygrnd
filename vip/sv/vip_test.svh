class vip_base_test extends uvm_test;
  
  // configuation. Automation
  
  // class members. Automation
  
  // macro for factory registeration and automation
  // of class members
  `uvm_component_utils(vip_base_test)
  
  // protected virtual if or if proxy. No automation
  protected vip_vif vif;
  
  // test's components. No automation
  vip_env env;
  
  // constructor
  function new (string name = "vip_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  // build phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
        
    check_vip_vif();
    uvm_config_db#(vip_vif)::set(this,"*","vip_vif", vif);
    
    env = vip_env::type_id::create("env", this);
  endfunction
  
  // end of elaboration
  virtual function void end_of_elaboration();
    print();
  endfunction
  
  // all dropped with drain time
  virtual task all_dropped (uvm_objection objection, uvm_object source_obj, 
                    string description, int count);
    objection.print();
    if (objection == uvm_test_done)
      begin
        `uvm_info($sformatf("%s: all_dropped", this.get_name()), 
                  " objection == uvm_test_done",UVM_LOW)
        `uvm_info($sformatf("%s: all_dropped", this.get_name()), 
                  $sformatf("get_objection_count=%0d", objection.get_objection_count(this)), 
                  UVM_LOW)
        `uvm_info($sformatf("%s: all_dropped", this.get_name()), 
                  $sformatf("get_objection_total=%0d", objection.get_objection_total), 
                  UVM_LOW)
        repeat(15) @(this.vif.vip_tb_mod.tb_ck);

      end
  endtask
  
  extern function void init_vseqr(vip_base_vseq _vseq);
  
  extern function void check_vip_vif();
    
endclass
    
    function void vip_base_test::init_vseqr(vip_base_vseq _vseq);
    	_vseq._seqr = this.env.agent.seqr;  
    endfunction
    
    function void vip_base_test::check_vip_vif();
      
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
    
// tests
    
    class simple_test extends vip_base_test;
  
      uvm_component seqr;
      
      // configuation. Automation
      
      // class members. Automation
      vip_base_sequence base_sequence;
      
      // macro for factory registeration and automation
      // of class members
      `uvm_component_utils_begin(simple_test)
      `uvm_field_object(base_sequence, UVM_DEFAULT)
      `uvm_component_utils_end

      // protected virtual if or if proxy. No automation
      
      // test's components. No automation      
      
      // constructor
      function new (string name = "simple_test", 
                    uvm_component parent = null);
        super.new(name, parent);
      endfunction
      
      // build phase
      
      // end of elaboration
      
      // run phase
      virtual task run_phase(uvm_phase phase);
        `uvm_info($sformatf("%s", this.get_name()), 
                  $sformatf("get_objection_count=%0d", 
                            phase.get_objection_count(this)), UVM_LOW) 
        phase.raise_objection(this, "test is raising an ojection");
        `uvm_info($sformatf("%s", this.get_name()), 
                  $sformatf("get_objection_count=%0d", 
                            phase.get_objection_count(this)), UVM_LOW)
        
        // find the sequencer
        //seqr = uvm_top.find("*seqr");
        //seqr.print();
        
        // create the sequence
        base_sequence = vip_base_sequence::type_id::create("base_sequence");
        
        // start it on the sequencer
        base_sequence.start(env.agent.seqr);
        
        #20 phase.drop_objection(this, "test is dropping the objection");
        `uvm_info($sformatf("%s", this.get_name()), 
                  $sformatf("get_objection_count=%0d", 
                            phase.get_objection_count(this)), UVM_LOW) 
      endtask
    
    endclass

        
    class simple_vseq_test extends vip_base_test;
  
      // configuation. Automation
      
      // class members. Automation
      vseq_simple _vseq;
      
      // macro for factory registeration and automation
      // of class members
      `uvm_component_utils_begin(simple_vseq_test)
      `uvm_field_object(_vseq, UVM_DEFAULT)
      `uvm_component_utils_end

      // protected virtual if or if proxy. No automation

      // test's components. No automation      
      
      // constructor
      function new (string name = "simple_vseq_test", 
                    uvm_component parent = null);
        super.new(name, parent);
      endfunction
      
      // build phase
      
      // end of elaboration
      
      // run phase
      virtual task run_phase(uvm_phase phase);
       
        phase.raise_objection(this, "test is raising an ojection");
       
        // create the vsequence
        _vseq = vseq_simple::type_id::create("_vseq");
        
        // initialize the sequencer handles
        init_vseqr(_vseq);
        
        // start the vseq on null sequencer
        _vseq.start(null);
        
        #20 phase.drop_objection(this, "test is dropping the objection");

      endtask
      
    endclass
