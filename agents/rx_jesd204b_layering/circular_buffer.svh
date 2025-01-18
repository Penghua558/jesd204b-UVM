class circular_buffer#(type T);
protected T buffer[];
// total size of buffer, includes the wasted element slot
protected int N;
protected int writeIndx = 0;
protected int readIndx = 0;

function new(int capacity);
    N = capacity + 1;
    buffer = new[N];
    writeIndx = 0;
    readIndx = 0;
endfunction


function void reset();
// empty the buffer
    writeIndx = 0;
    readIndx = 0;
endfunction


function int get_capacity();
// returns capacity of the buffer in number of elements,
// returns -1 if buffer has not been allocated memory yet
    if (buffer != null)
        return N-1;
    else
        return -1;
endfunction


function bit is_full();
// return 1 if buffer is full, return 0 otherwise
    return ((writeIndx + 1) % N == readIndx);
endfunction


function bit is_empty();
// return 1 if buffer is empty, return 0 otherwise
    return (writeIndx == readIndx);
endfunction


function bit put(T item);
// put item into buffer, return 1 if operation is successful, return
// 0 otherwise
    if (is_full())
        return 0;
    buffer[writeIndx] = item;
    writeIndx = (writeIndx + 1) % N;
    return 1;
endfunction


function bit get(output T item);
// read the buffer, get the first element and put it into item.
// Returns 1 if operation is successful, returns 0 otherwise
    if (is_empty())
        return 0;
    item = buffer[readIndx];
    readIndx = (readIndx + 1) % N;
    return 1;
endfunction

endclass: circular_buffer
