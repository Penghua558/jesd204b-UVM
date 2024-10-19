// randomly configures register motor_speed
class rand_speed_sequence extends apb_bus_sequence_base;

  `uvm_object_utils(rand_speed_sequence)

  function new(string name = "rand_speed_sequence");
    super.new(name);
  endfunction

  task body;
    super.body;

    assert(spi_rb.MOTORSPD.randomize());
    spi_rb.MOTORSPD.update(status, .path(UVM_FRONTDOOR), .parent(this));
    // Get the desired motor speed
    data = spi_rb.MOTORSPD.get();
  endtask: body

endclass: rand_speed_sequence
