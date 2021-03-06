// sequence classes
class vip_simple_sequence extends vip_base_sequence;
  
  `uvm_object_utils(vip_simple_sequence)
  
  function new (string name = "vip_simple_sequence");
    super.new(name);
    set_automatic_phase_objection(1);
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
    set_automatic_phase_objection(1);
  endfunction
    
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
    poke_reg(.rg(reg_model.vip_rf.ctrl), .status(status), 
             .value('h12345), .kind("RTL"));
    
    #50ns;
    
    // backdoor read
    peek_reg(.rg(reg_model.vip_rf.ctrl), .status(status), 
             .value(rd_val), .kind("RTL"));
    assert(rd_val == 'h12345);
    
    reg_model.vip_rf.ctrl.print();
    `uvm_info("VIP_SIMPLE_REG_SEQ", 
              $sformatf("Read value is %d", rd_val), UVM_LOW)
  endtask
endclass

// test virtual sequences
class simple_vseq extends base_vseq;
  
  `uvm_object_utils(simple_vseq)
  
  vip_base_sequence req;
  
  function new (string name = "simple_vseq");
    super.new(name);
    set_automatic_phase_objection(1);
  endfunction 
    
  virtual task body();    
    req = vip_base_sequence::type_id::create("req");
    if (req.get_automatic_phase_objection())
      begin
        `uvm_info($sformatf("%s", this.get_name()), 
                  "Automatic phase objection is set", UVM_LOW)
      end
    `uvm_do_on(req, p_sequencer.seqr)    
  endtask
  
endclass

// test virtual sequence with reg_seq
class simple_reg_vseq extends base_vseq;
  
  `uvm_object_utils(simple_reg_vseq)
  
  vip_simple_reg_seq reg_req;
  
  function new (string name = "simple_reg_vseq");
    super.new(name);
    set_automatic_phase_objection(1);
  endfunction 
    
  virtual task body();
    reg_req = vip_simple_reg_seq::type_id::create("reg_req");  
    `uvm_do_on(reg_req, p_sequencer.seqr)    
  endtask
  
endclass

// test virtual seq calling c
class simple_c_vseq extends base_vseq;
  
  `uvm_object_utils(simple_c_vseq)
  
  function new (string name = "simple_c_vseq");
    super.new(name);
  endfunction
  
endclass

// test classes
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
  virtual function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    //vip_base_sequence::type_id::set_type_override(
      //vip_simple_sequence::get_type());
    set_type_override_by_type(vip_base_sequence::get_type(), 
                            vip_simple_sequence::get_type());   
  endfunction
  
  // end of elaboration
  
  // run phase
  virtual task run_phase(uvm_phase phase);
    
    //phase.raise_objection(this, "test is raising an ojection");
    
    // find the sequencer
    //uvm_component seqr;
    //seqr = uvm_top.find("*seqr");
    //seqr.print();
    
    // create the sequence
    base_sequence = vip_base_sequence::type_id::create("base_sequence");
    
    // call the following to enable starting_phase.raise/drop_objection(..)
    base_sequence.set_starting_phase(phase); // uvm-1.2
    
    // stop the propagation of the objection through the hierarchy
    //base_sequence.get_starting_phase().get_objection().set_propagate_mode(0);
    
    // start it on the sequencer
    base_sequence.start(tb.env.agent.seqr);

    //phase.drop_objection(this, "test is dropping the objection");
  endtask
  
endclass

class vseq_base_test extends vip_base_test;
  
  // configuation. Automation
  // class members. Automation
  
  // macro for factory registeration and automation
  // of class members
  `uvm_component_utils(vseq_base_test)
  
  // test's components. No automation
  base_vseq vseq;     
  
  // constructor
  function new (string name = "vseq_base_test", 
                uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  // build phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);    
  endfunction
  
  // end of elaboration
  
  // run phase
  virtual task run_phase(uvm_phase phase);
     
    // create the vsequence.
    vseq = base_vseq::type_id::create("vseq");
    
    // call the following to enable starting_phase.raise/drop_objection(..)
    vseq.set_starting_phase(phase); // uvm-1.2

    // start the vseq
    // explicit de-activation of calls to task pre/post body
    // vseq.start(tb.vseqr, null, -1, 0);
    vseq.start(tb.vseqr);    
    
  endtask
  
endclass

class vseq_simple_test extends vseq_base_test;
  
  `uvm_component_utils(vseq_simple_test)
  
  function new (string name = "vseq_simple_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    //vip_base_sequence::type_id::set_type_override(
      //vip_simple_sequence::get_type());
    set_type_override_by_type(vip_base_sequence::get_type(), 
                            vip_simple_sequence::get_type());
    // run the simple_vseq
    //set_type_override_by_type(base_vseq::get_type(), 
                              //simple_vseq::get_type());
    // run the simple_reg_vseq
    set_type_override_by_type(base_vseq::get_type(), 
                              simple_reg_vseq::get_type());    
  endfunction
  
endclass

// c test
class c_base_test extends vseq_base_test;
    
  `uvm_component_utils(c_base_test)
  
  function new (string name = "c_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  export "DPI-C" function send_tr;
  
  // only imported context tasks can call exported tasks
  import "DPI-C" context task start_c();


  // run phase
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this, "test is raising an ojection");
    
    start_c();
    
    phase.drop_objection(this, "test is dropping an ojection");
  endtask

  
  function void send_tr();
    `uvm_info($sformatf("%s", this.get_name()), "Hello from SV", UVM_LOW)
  endfunction
  
  
endclass


