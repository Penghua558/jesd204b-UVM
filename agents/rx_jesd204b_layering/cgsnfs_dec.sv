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

endpackage: cgsnfs_dec
