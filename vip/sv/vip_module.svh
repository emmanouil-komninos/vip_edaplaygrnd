// register sequences


// predictor


// module uvc
class vip_module_uvc extends uvm_env;
  
  // pointer to register model. Automation
  vip_reg_model_c vip_reg_model;
  
  // adapter object reg 2 apb. Automation
  vip_reg2cbus_adapter reg2cbus;
  
  `uvm_component_utils_begin(vip_module_uvc)
  `uvm_field_object(vip_reg_model, UVM_DEFAULT | UVM_REFERENCE)
  `uvm_field_object(reg2cbus, UVM_DEFAULT | UVM_REFERENCE)
  `uvm_component_utils_end
  
  // predictor
  uvm_reg_predictor#(vip_base_seq_item) cbus_predictor;
  
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  extern function void build_phase (uvm_phase phase);
  extern function void connect_phase (uvm_phase phase);
  
endclass
