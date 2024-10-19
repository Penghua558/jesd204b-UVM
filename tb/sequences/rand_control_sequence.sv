// randomly configures register motor_speed and bending
class rand_control_sequence extends apb_bus_sequence_base;

  `uvm_object_utils(rand_control_sequence)

  function new(string name = "rand_control_sequence");
    super.new(name);
  endfunction

  task body;
    super.body;

    assert(spi_rb.MOTORSPD.randomize());
    assert(spi_rb.BENDING.randomize());
    spi_rb.MOTORSPD.update(status, .path(UVM_FRONTDOOR), .parent(this));
    spi_rb.BENDING.update(status, .path(UVM_FRONTDOOR), .parent(this));
  endtask: body

endclass: rand_control_sequence
