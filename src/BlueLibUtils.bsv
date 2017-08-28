package BlueLibUtils;

function b roundUpToMultiple(b num, b multiple)
    provisos(Eq#(b), Arith#(b));
    let ret = num;

    if(multiple != 0)
        ret = ((num + multiple - 1) / multiple) * multiple;

    return ret;
endfunction

function b roundDownToMultiple(b num, b multiple)
    provisos(Eq#(b), Arith#(b));
    let ret = num;
    if(multiple != 0)
        ret = (num / multiple) * multiple;

    return ret;
endfunction

endpackage