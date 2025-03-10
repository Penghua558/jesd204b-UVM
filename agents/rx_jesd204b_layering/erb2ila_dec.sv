package erb2ila_dec;

typedef bit[7:0] frame_data[];

// this statemachine is a part of JESD204B standard, but the name of states
// are not assigned in the protocol so I made these names up
typedef enum {
    ILA_WAIT,
    ILA_EVAL,
    ILA_ADJ,
    ILA_RPT
    } ilastate_e;

endpackage: erb2ila_dec
