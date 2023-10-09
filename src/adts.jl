
@adt ZXWSpiderType begin
    W
    H
    D

    struct Z
        p::Parameter
    end

    struct X
        p::Parameter
    end

    struct Input
        qubit::Int
    end

    struct Output
        qubit::Int
    end
end

@const_use ZXWSpiderType:W, H, D, Z, X, Input, Output
