function evaluate(expr)
    if self_evaluating(expr)
        expr
    else
        throw("Not implemented")
    end
end

function self_evaluating(expr)
    isa(expr, Int) || isa(expr, Bool) || isa(expr, String)
end

function metajulia_repl()
    while true
        print(">> ")
        println(evaluate(Meta.parse(readline())))
    end
end
