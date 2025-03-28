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

//
// Class Description:
//
//
class deserializer_sequencer extends uvm_sequencer#(deserializer_trans);

// UVM Factory Registration Macro
//
`uvm_component_utils(deserializer_sequencer)

// Standard UVM Methods:
extern function new(string name="deserializer_sequencer", 
uvm_component parent = null);

endclass: deserializer_sequencer

function deserializer_sequencer::new(string name="deserializer_sequencer", 
    uvm_component parent = null);
  super.new(name, parent);
endfunction
