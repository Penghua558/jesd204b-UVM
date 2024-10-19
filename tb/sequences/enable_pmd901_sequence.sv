// enable PMD901, other registers are untouched
class enable_pmd901_sequence extends apb_bus_sequence_base;

  `uvm_object_utils(enable_pmd901_sequence)

  function new(string name = "enable_pmd901_sequence");
    super.new(name);
  endfunction

  task body;
    super.body;

    data[15:0] = 16'd1;
    spi_rb.PARK.write(status, data, .path(UVM_FRONTDOOR), .parent(this));
  endtask: body

endclass: enable_pmd901_sequence
