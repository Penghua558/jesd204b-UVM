// Base class that used by all the other sequences in the
// package:
//
// Gets the handle to the register model - spi_rm
//
// Contains the data and status fields used by most register
// access methods
//
class apb_bus_sequence_base extends uvm_sequence #(uvm_sequence_item);

  `uvm_object_utils(apb_bus_sequence_base)

  // SPI Register block
  spi_reg spi_rb;

  // SPI env configuration object (containing a register model handle)
  env_config m_cfg;

  // Properties used by the various register access methods:
  rand uvm_reg_data_t data;  // For passing data
  uvm_status_e status;       // Returning access status

  function new(string name = "apb_bus_sequence_base");
    super.new(name);
  endfunction

  // Common functionality:
  // Getting a handle to the register model
  task body;
    if(m_cfg == null) begin
      `uvm_fatal(get_full_name(), "env_config is null")
    end
    spi_rb = m_cfg.spi_rb;
  endtask: body

endclass: apb_bus_sequence_base
