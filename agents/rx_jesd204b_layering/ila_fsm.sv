import erb2ila_dec::*;
class ILA_StateMachine;
    rx_jesd204b_layering_config m_cfg;
    ilastate_e currentState;
    ilastate_e nextState;
    bit [2:0] kcounter;
    int ocounter;
    // 0 - increment ocounter at reception of next octet
    // 1 - reset ocounter at reception of next octet
    bit reset_octet_counter;
    int previous_af_position;
    // in software FSM, transition is called event, data/stimulus from
    // external associated with the event is event data
    // In this FSM, event data to cause transition is decoded symbol from
    // CGS FSM
    cgsnfs_trans eventData;

    function new();
        currentState = ILA_WAIT;
        kcounter = 3'd0;
        ocounter = 0;
        reset_octet_counter = 1'b0;
        previous_af_position = 0;
    endfunction

    extern function void update_currentstate();
    extern function void get_nextstate(cgsnfs_trans eventData);
    // do things based on current state and updated cgsnfs_trans
    extern function void state_func(cgsnfs_trans cgs);
    extern function void check_alignment(cgsnfs_trans t);
    extern function bit cross_coupling();
    extern function bit is_link_initialization();
endclass

function void ILA_StateMachine::update_currentstate();
    currentState = nextState;
endfunction

function void ILA_StateMachine::get_nextstate(cgsnfs_trans eventData);
    case(currentState)
        ILA_WAIT: begin
            if (is_link_initialization())
                nextState = ILA_EVAL;
            else
                nextState = ILA_WAIT;
        end
        FS_DATA: begin
            if (eventData.data == K && eventData.is_control_word)
                nextState = FS_CHECK;
            else
                nextState = FS_DATA;
        end
        FS_CHECK: begin
            if (kcounter == 3'd4)
                nextState = FS_INIT;
            else if (!(eventData.data == K && eventData.is_control_word))
                nextState = FS_DATA;
            else
                nextState = FS_CHECK;
        end
        default: nextState = FS_INIT;
    endcase
endfunction

function void ILA_StateMachine::state_func(cgsnfs_trans cgs);
    case(currentState)
        FS_INIT: ocounter = 0;
        FS_DATA: begin
            kcounter = 3'd0;
            if (reset_octet_counter)
                ocounter = 0;
            else
                ocounter = (ocounter + 1) % m_cfg.F;
            reset_octet_counter = 1'b0;
            check_alignment(cgs);
        end
        FS_CHECK: begin
            kcounter++;
            if (reset_octet_counter)
                ocounter = 0;
            else
                ocounter = (ocounter + 1) % m_cfg.F;
            reset_octet_counter = 1'b0;
            check_alignment(cgs);
        end
        default: ocounter = 0;
    endcase
    cgs.ifsstate = currentState;
    cgs.o_position = ocounter;
endfunction

function void ILA_StateMachine::check_alignment(cgsnfs_trans t);
    if (t.is_control_word) begin
        if ((t.data == A || t.data == F) && t.valid) begin
            `uvm_info("IFS", "A/F detected", UVM_HIGH)
            // discrambling enabled
            if (m_cfg.scrambling_enable)
                t.is_control_word = 1'b0;

            if (((ocounter == previous_af_position) || cross_coupling()) &&
                t.valid) begin
                `uvm_info("IFS", "frame aligned, resetting ocounter", UVM_HIGH)
                reset_octet_counter = 1'b1;
            end
            if (t.valid || ocounter == (m_cfg.F-1))
                previous_af_position = ocounter;
        end
    end
endfunction

function bit ILA_StateMachine::cross_coupling();
// when frame misalignment is expected to happen transmitter disable IFS
// via control interface, for now it's a PLACEHOLDER
    return 0;
endfunction

function bit ILA_StateMachine::is_link_initialization();
// returns 1 when link initialization is detected
// returns 0 if no link initialization is detected
endfunction
