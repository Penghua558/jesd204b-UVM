package cgsnfs_dec;
// CGS statemachine's states
typedef enum {
    CS_INIT,
    CS_CHECK,
    CS_DATA
} cgsstate_e;

// Initial frame synchronization statemachine's states
typedef enum {
    FS_INIT,
    FS_CHECK,
    FS_DATA
} ifsstate_e;

parameter bit[7:0] K = 8'b101_11100;
endpackage: cgsnfs_dec
