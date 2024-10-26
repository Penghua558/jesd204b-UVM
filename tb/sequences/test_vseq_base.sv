//------------------------------------------------------------
//   Copyright 2010-2018 Mentor Graphics Corporation
//   All Rights Reserved Worldwide
//
//   Licensed under the Apache License, Version 2.0 (the
//   "License"); you may not use this file except in
//   compliance with the License.  You may obtain a copy of
//   the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in
//   writing, software distributed under the License is
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied.  See
//   the License for the specific language governing
//   permissions and limitations under the License.
//------------------------------------------------------------

// Base class to get sub-sequencer handles
//
// Note that this virtual sequence uses resources to get
// the handles to the target sequencers
//
// This means that we do not need a virtual sequencer
//
class test_vseq_base extends uvm_sequence #(uvm_sequence_item);

  `uvm_object_utils(test_vseq_base)

  function new(string name = "test_vseq_base");
    super.new(name);
  endfunction

  // Virtual sequencer handles
  enc_bus_sequencer enc_bus_sequencer_h;

  // Handle for env config to get to interrupt line
  env_config m_cfg;

  // This set up is required for child sequences to run
  task body;
    if(enc_bus_sequencer_h==null) begin
      `uvm_fatal("SEQ_ERROR", "Encoder bus sequencer handle is null")
    end

    if(m_cfg==null) begin
      `uvm_fatal("CFG_ERROR", "Configuration handle is null")
    end
  endtask: body
endclass: test_vseq_base
