class vip_base_test extends uvm_test;
  
  // configuation. Automation
  // class members. Automation
  
  // macro for factory registeration and automation
  // of class members
  `uvm_component_utils(vip_base_test)
  
  // test's components. No automation
  vip_tb tb;
  
  // constructor
  function new (string name = "vip_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  // build phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);    
    tb = vip_tb::type_id::create("tb", this);
  endfunction
    
  // end of elaboration
  virtual function void end_of_elaboration();
    print();
  endfunction
  
  // all dropped with drain time
  virtual task all_dropped (uvm_objection objection, uvm_object source_obj, 
                    string description, int count);

    if (objection == uvm_test_done)
      begin
        `uvm_info($sformatf("%s: all_dropped", this.get_name()), 
                  " objection == uvm_test_done",UVM_LOW)
        
        `uvm_info($sformatf("%s: all_dropped", this.get_name()), 
                  $sformatf("get_objection_count=%0d",
                            objection.get_objection_count(this)),
                  UVM_LOW)
        `uvm_info($sformatf("%s: all_dropped", this.get_name()), 
                  $sformatf("get_objection_total=%0d",
                            objection.get_objection_total), 
                  UVM_LOW)
        repeat(15) @(this.tb.vif.vip_tb_mod.tb_ck);
      end
  endtask
    
endclass

      
// tests


class simple_test extends vip_base_test;
  
  // configuation. Automation
  
  // class members. Automation
  vip_base_sequence base_sequence;
  
  // macro for factory registeration and automation
  // of class members
  `uvm_component_utils_begin(simple_test)
  `uvm_field_object(base_sequence, UVM_DEFAULT)
  `uvm_component_utils_end
  
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
    //uvm_component seqr;
    //seqr = uvm_top.find("*seqr");
    //seqr.print();
    
    // create the sequence
    base_sequence = vip_base_sequence::type_id::create("base_sequence");
    
    // start it on the sequencer
    base_sequence.start(tb.env.agent.seqr);
    
    #20 phase.drop_objection(this, "test is dropping the objection");
    `uvm_info($sformatf("%s", this.get_name()), 
              $sformatf("get_objection_count=%0d", 
                        phase.get_objection_count(this)), UVM_LOW) 
  endtask
  
endclass


// test virtual sequence
class vseq_simple extends base_vseq;
  
  `uvm_object_utils(vseq_simple)
  
  vip_base_sequence req;
  
  function new (string name = "vseq_simple");
    super.new(name);
  endfunction 
    
  task body();
    req = vip_base_sequence::type_id::create("req");    
    `uvm_do_on(req, p_sequencer.seqr)    
  endtask
  
endclass


class vseq_simple_test extends vip_base_test;
  
  // configuation. Automation
  // class members. Automation
  vseq_simple vseq;
  
  // macro for factory registeration and automation
  // of class members
  `uvm_component_utils(vseq_simple_test)
  
  // test's components. No automation      
  
  // constructor
  function new (string name = "vseq_simple_test", 
                uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  // build phase
  // end of elaboration
  
  // run phase
  virtual task run_phase(uvm_phase phase);
    
    //phase.raise_objection(this, "test is raising an ojection");
     
    // create the vsequence.
    vseq = vseq_simple::type_id::create("vseq");
    
    // call the following to enable starting_phase.raise/drop_objection(..)
    //vseq.set_starting_phase(phase); // uvm-1.2

    // start the vseq
    // explicit de activation of calls to task pre/post body
    // vseq.start(tb.vseqr, null, -1, 0);
    vseq.start(tb.vseqr);    
    
    //#20 phase.drop_objection(this, "test is dropping the objection");
    
  endtask
  
endclass
