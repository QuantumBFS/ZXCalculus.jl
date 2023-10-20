@adt ZWSpiderType begin
    # the following spiders form a complete set of
    # generators for pW fragment

    W # W Spider

    fSWAP  # fermonic SWAP spider

    # binary Z Spider
    struct binZ
        r::Parameter
    end

    # adding SWAP gives you the ferminoic ZW fragment
    SWAP

    # adding 1-nary Z spider gives you the entire ZW calculus
    # TODO: proof of it is not in the paper, need to do
    struct monoZ
        r::Parameter
    end

    struct Input
        qubit::Int
    end

    struct Output
        qubit::Int
    end

end

@const_use ZWSpiderType:W, fSWAP, binZ, SWAP, monoZ, Input, Output
