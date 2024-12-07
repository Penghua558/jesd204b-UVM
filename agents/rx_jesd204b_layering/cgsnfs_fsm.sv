import cgsnfs_dec::*;
class CGS_StateMachine;
    cgsstate_e currentState;
    cgsstate_e nextState;
    bit [2:0] kcounter;
    bit [1:0] icounter;
    bit [2:0] vcounter;
    // in software FSM, transition is called event, data/stimulus from
    // external associated with the event is event data
    // In this FSM, event data to cause transition is decoded symbol from
    // deser2dec_monitor
    decoder_8b10b_trans eventData;

    extern function new();
    extern function void get_nextstate(decoder_8b10b_trans eventData);
    // do things based on current state and updated cgsnfs_trans
    extern function void state_func(cgsnfs_trans cgs);

endclass

function CGS_StateMachine::new();
    currentState = CS_INIT;
    kcounter = 3'd0;
    icounter = 2'd0;
    vcounter = 3'd0;
endfunction

function void CGS_StateMachine::get_nextstate(decoder_8b10b_trans eventData);
endfunction

function void CGS_StateMachine::state_func(cgsnfs_trans cgs);
endfunction

class IFS_StateMachine;
    ifsstate_e currentState;
    ifsstate_e nextState;
endclass
