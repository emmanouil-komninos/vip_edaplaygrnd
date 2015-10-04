// vip package
package vip_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

typedef virtual design_if vip_vif;

`include "vip.svh"

endpackage

// test package
package vip_test_pkg;
	import uvm_pkg::*;
	`include "uvm_macros.svh"
	import vip_pkg::*;

	`include "vip_register.svh"
	`include "vip_module.svh"
	`include "vip_tb.svh"
	`include "vip_seq_lib.svh"
	`include "vip_test.svh"
endpackage
