// vip package
package vip_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

typedef virtual design_if vip_vif;

`include "vip.svh"

endpackage


// virtual sequence package
package vip_vseq_pakcage;

	import uvm_pkg::*;
	`include "uvm_macros.svh"

	import vip_pkg::*;

	// vip base virtual sequence using sequencer handles
	class vip_base_vseq extends uvm_virtual_sequence;
  
  	`uvm_object_utils(vip_base_vseq)
  
  	// Sequencer handle
  	vip_sequencer _seqr;
  
  	function new (string name = "vip_base_vseq");
	    super.new(name);
  	endfunction
  
	endclass

	class vseq_simple extends vip_base_vseq;
  
  	`uvm_object_utils(vseq_simple)
  
  	function new (string name = "vseq_simple");
      super.new(name);
  	endfunction
      
      task body();
        
    	vip_base_sequence seq =
      	  vip_base_sequence::type_id::create("seq");
	    
	    seq.start(_seqr);
      
      endtask
      
    endclass

endpackage


// test package
package vip_test_pkg;
	import uvm_pkg::*;
	`include "uvm_macros.svh"
	import vip_pkg::*;

	import vip_vseq_pakcage::*;
	`include "vip_test.svh"
endpackage

