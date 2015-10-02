// register sequences


// module uvc
class vip_module_uvc extends uvm_env;
  
  // pointer to register model. Automation
  vip_reg_model_c reg_model;
  
  // adapter object reg 2 apb. Automation
  vip_reg_cbus_adapter reg_cbus;
  
  `uvm_component_utils_begin(vip_module_uvc)
  `uvm_field_object(reg_model, UVM_DEFAULT | UVM_REFERENCE)
  `uvm_field_object(reg_cbus, UVM_DEFAULT | UVM_REFERENCE)
  `uvm_component_utils_end
  
  // predictor. No automation
  uvm_reg_predictor#(vip_base_seq_item) cbus_predictor;
  
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  extern function void build_phase (uvm_phase phase);
  extern function void connect_phase (uvm_phase phase);
  
endclass
    
    function void vip_module_uvc::build_phase(uvm_phase phase);
      super.build_phase(phase);
      
      // reg_model is assigned automatically through set in the TB
      reg_model.print();
      // Create adapter
      reg_cbus = vip_reg_cbus_adapter::type_id::create("reg_cbus");
      //Create predictor
      cbus_predictor = uvm_reg_predictor#(vip_base_seq_item)::type_id::create("cbus_predictor", this);
    endfunction
    
    function void vip_module_uvc::connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      // connect adapter and register map to predictor
      cbus_predictor.map = reg_model.default_map;
      cbus_predictor.adapter = reg_cbus;
    endfunction
